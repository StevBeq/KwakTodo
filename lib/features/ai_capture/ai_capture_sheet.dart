library;

import 'dart:typed_data' show Uint8List;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/ai/ai_result.dart';
import '../../core/ai/gemini_service.dart';
import '../../core/domain/models.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/toast.dart';
import 'ai_capture_panes.dart';
import 'ai_draft_preview.dart';
import 'ai_mode.dart';

/// Sheet "Tanya AI" — prototype (304–350). Saat user tekan "Review
/// Sekarang" sheet mengEMBALIKAN (drafts, mode) — alur review & acc
/// berjalan di ai_capture_flow.dart (pemanggil).
Future<(List<TaskDraft>, AiMode)?> showAiCaptureSheet(BuildContext context) =>
    showModalBottomSheet<(List<TaskDraft>, AiMode)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => const AiCaptureSheet(),
    );

class AiCaptureSheet extends StatefulWidget {
  const AiCaptureSheet({super.key});

  @override
  State<AiCaptureSheet> createState() => _AiCaptureSheetState();
}

class _AiCaptureSheetState extends State<AiCaptureSheet> {
  final _sttCtrl = TextEditingController();
  final _txtCtrl = TextEditingController();
  final SpeechToText _stt = SpeechToText();
  ({Uint8List bytes, String name})? _photo;
  AiMode _mode = AiMode.text;
  bool _listening = false;
  bool _busy = false;
  bool _sttReady = false;
  List<TaskDraft>? _drafts;

  @override
  void dispose() {
    _sttCtrl.dispose();
    _txtCtrl.dispose();
    super.dispose();
  }

  bool get _hasInput => switch (_mode) {
    AiMode.photo => _photo != null,
    _ => _rawText.trim().isNotEmpty,
  };

  String get _rawText => _mode == AiMode.voice ? _sttCtrl.text : _txtCtrl.text;

  String get _sttHint => switch ((_listening, _sttReady)) {
    (true, _) => '🎙️ Mendengarkan… ketuk lagi untuk berhenti',
    (_, true) => 'Selesai — cek teks lalu parse ✨',
    _ => 'Ketuk untuk bicara… (Bahasa Indonesia)',
  };

  // ===== Ganti mode — input masing-masing tak tercampur; hasil parse lama
  // hangus (proto setMode/closeAI). =====
  void _pickMode(AiMode m) => setState(() {
    _mode = m;
    _drafts = null;
    _busy = false;
    _listening = false;
  });

  // ===== VOICE — STT on-device Bahasa Indonesia (MASTER_SPEC §4.2). =====
  Future<void> _toggleMic() async {
    if (_listening) {
      await _stt.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ready = await _stt.initialize();
    setState(() => _sttReady = ready);
    if (!ready) {
      if (mounted) {
        showAppToast(
          context,
          'Fitur suara tak tersedia di HP ini — pakai Teks',
        );
      }
      return;
    }
    await _stt.listen(
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        localeId: 'id_ID',
      ),
      onResult: (r) {
        if (!mounted) return;
        setState(() => _sttCtrl.text = r.recognizedWords);
      },
    );
    if (mounted) setState(() => _listening = true);
  }

  // ===== FOTO — kamera/galeri dikompres native image_picker
  // (maxWidth 1280 q80); file lewat flutter_image_compress. =====
  Future<void> _pickPhoto(ImageSource source) async {
    final x = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (x == null) return;
    await _setPhoto(await x.readAsBytes(), _photoName(source));
  }

  String _photoName(ImageSource source) {
    final ts = DateTime.now().millisecondsSinceEpoch % 10000;
    return source == ImageSource.camera
        ? 'IMG-camera-$ts.jpg'
        : 'dari-galeri-$ts.jpg';
  }

  Future<void> _pickFile() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final f = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (f == null) return;
    var bytes = await f.readAsBytes();
    // Jalur file tidak lewat image_picker → kompres di sini (ARCH §4.3).
    try {
      bytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 1280,
        minHeight: 1280,
        quality: 80,
        format: CompressFormat.jpeg,
      );
    } catch (_) {
      if (mounted) showAppToast(context, 'Gagal memproses gambar');
      return;
    }
    if (bytes.isEmpty) {
      if (mounted) showAppToast(context, 'Gambar tidak valid');
      return;
    }
    final ts = DateTime.now().millisecondsSinceEpoch % 10000;
    await _setPhoto(bytes, 'file-$ts.jpg');
  }

  Future<void> _setPhoto(Uint8List bytes, String name) async {
    if (!mounted) return;
    setState(() {
      _photo = (bytes: bytes, name: name);
      _drafts = null; // foto baru → hasil parse lama hangus
    });
  }

  // ===== PARSE → Gemini (MASTER_SPEC §4.2): gagal = toast error + input
  // dipertahankan; sukses = preview drafts + tombol jadi Review Sekarang.
  Future<void> _parse() async {
    if (!_hasInput) {
      showAppToast(context, 'Input masih kosong ✋');
      return;
    }
    final voiceText = _sttCtrl.text.trim();
    final promptText = _txtCtrl.text.trim();
    if (_mode == AiMode.text && promptText.length > 2000) {
      showAppToast(context, 'Teks maksimal 2.000 karakter ✋');
      return;
    }
    final settings = context.read<SettingsProvider>();
    final service = GeminiService(keys: () => settings.apiKeys.toList());

    setState(() => _busy = true);
    final r = switch (_mode) {
      AiMode.voice => await service.parseText(
        voiceText.length > 2000 ? voiceText.substring(0, 2000) : voiceText,
      ),
      AiMode.text => await service.parseText(promptText),
      AiMode.photo => await service.parseImage(_photo!.bytes),
    };
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case final OkResult<List<TaskDraft>> ok:
        if (ok.value.isEmpty) {
          showAppToast(
            context,
            'AI tidak menemukan tugas — coba deskripsi lain',
          );
          return;
        }
        setState(() => _drafts = ok.value);
      case final ErrResult<List<TaskDraft>> err:
        showAppToast(context, err.error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.sheet,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.grabber,
                        borderRadius: AppRadius.chip,
                      ),
                    ),
                  ),
                  const CaptureHead(),
                  const SizedBox(height: 12),
                  ModeTabs(active: _mode, onPick: _pickMode),
                  const SizedBox(height: 20),
                  _pane(),
                  if (_drafts != null) DraftPreviewList(drafts: _drafts!),
                  const SizedBox(height: 20),
                  _parseButton(),
                  const SizedBox(height: 8),
                  const Text(
                    'Data dikirim ke Google Gemini untuk diproses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pane() {
    switch (_mode) {
      case AiMode.voice:
        return VoicePane(
          listening: _listening,
          sttHint: _sttHint,
          ctrl: _sttCtrl,
          onMic: _toggleMic,
        );
      case AiMode.text:
        return TextPane(ctrl: _txtCtrl);
      case AiMode.photo:
        return PhotoPane(
          photo: _photo,
          onCamera: () => _pickPhoto(ImageSource.camera),
          onGallery: () => _pickPhoto(ImageSource.gallery),
          onFile: _pickFile,
        );
    }
  }

  Widget _parseButton() {
    final toReview = _drafts != null;
    return FilledButton(
      onPressed: _busy ? null : (toReview ? _goReview : _parse),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: _busy
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.surface,
                  ),
                ),
                SizedBox(width: 10),
                Text('Menganalisis…'),
              ],
            )
          : Text(toReview ? 'Review Sekarang' : 'Parse jadi Tugas'),
    );
  }

  void _goReview() => Navigator.pop(context, (_drafts!, _mode));
}
