library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ai/gemini_service.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/toast.dart';
import 'api_key_rows.dart';

/// Kartu API Key Gemini — prototype (211–220, 596–606): judul + tombol
/// Tambah, deskripsi fallback key, baris "Key N" + input + validasi online + hapus,
/// tombol Simpan API Keys (hanya simpan jika valid, MASTER_SPEC §6).
class ApiKeysCard extends StatefulWidget {
  const ApiKeysCard({super.key});

  @override
  State<ApiKeysCard> createState() => _ApiKeysCardState();
}

class _ApiKeysCardState extends State<ApiKeysCard> {
  List<TextEditingController> _controllers = [];
  final Map<int, bool?> _validationStatus = {};
  final Map<int, bool> _checkingRow = {};
  bool _saving = false;

  /// Key tersamar default (enh F6: jangan plain di layar), toggle mata
  /// untuk melihat saat mengetik/cek.
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SettingsProvider>().loadApiKeys();
      if (mounted) _rebuild(context.read<SettingsProvider>().apiKeys);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _rebuild(List<String> keys) {
    for (final c in _controllers) {
      c.dispose();
    }
    setState(() {
      _controllers = [for (final k in keys) TextEditingController(text: k)];
      _validationStatus.clear();
      _checkingRow.clear();
    });
  }

  void _addRow() => setState(() {
    _controllers.add(TextEditingController());
  });

  void _removeRow(int i) => setState(() {
    _controllers.removeAt(i).dispose();
    _validationStatus.remove(i);
    _checkingRow.remove(i);
  });

  void _onTextChange(int i) {
    if (_validationStatus[i] != null) {
      setState(() => _validationStatus[i] = null);
    }
  }

  Future<bool> _validateSingleKey(int i, {bool showToast = true}) async {
    final key = _controllers[i].text.trim();
    if (key.isEmpty) {
      if (showToast) showAppToast(context, 'Key ${i + 1} masih kosong');
      return false;
    }

    setState(() => _checkingRow[i] = true);
    final res = await GeminiService.validateApiKey(key);
    if (!mounted) return false;

    setState(() {
      _checkingRow[i] = false;
      _validationStatus[i] = res.isValid;
    });

    if (showToast) {
      if (res.isValid) {
        showAppToast(context, 'Key ${i + 1} valid & aktif! ✅');
      } else {
        showAppToast(
          context,
          'Key ${i + 1} tidak valid: ${res.error ?? 'Ditolak Google'} ❌',
        );
      }
    }
    return res.isValid;
  }

  Future<void> _save() async {
    final keys = _controllers.map((c) => c.text.trim()).toList();
    final filledIndices = <int>[];
    for (var i = 0; i < keys.length; i++) {
      if (keys[i].isNotEmpty) filledIndices.add(i);
    }

    if (filledIndices.isEmpty) {
      showAppToast(context, 'Belum ada key yang diisi');
      return;
    }

    setState(() => _saving = true);

    // Validasi semua key yang diisi secara online ke Google Gemini
    for (final idx in filledIndices) {
      // Jika belum divalidasi atau invalid, cek sekarang
      if (_validationStatus[idx] != true) {
        final ok = await _validateSingleKey(idx, showToast: false);
        if (!ok) {
          if (mounted) {
            setState(() => _saving = false);
            final keyText = keys[idx];
            showAppToast(
              context,
              'Key ${idx + 1} ($keyText) tidak valid! Periksa kembali key kamu ❌',
            );
          }
          return;
        }
      }
    }

    if (!mounted) return;
    await context.read<SettingsProvider>().saveApiKeys(keys);
    if (!mounted) return;
    setState(() => _saving = false);
    _rebuild([for (final t in keys) t]);
    showAppToast(
      context,
      '${filledIndices.length} API key valid & tersimpan di Secure Storage 🔐',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.key_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'API Key Gemini',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                // Toggle tampil/samar semua key biar bisa dicek saat nge-save.
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.muted,
                ),
                tooltip: _visible ? 'Sembunyikan key' : 'Tampilkan key',
              ),
              OutlinedButton(
                onPressed: _addRow,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primarySoft,
                  foregroundColor: AppColors.primaryDark,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14),
                    SizedBox(width: 4),
                    Text('Tambah'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Key 1 limit → app otomatis pakai key 2, dst. Key divalidasi ke Google '
            'sebelum disimpan agar AI siap digunakan.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _controllers.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            KeyRow(
              index: i,
              controller: _controllers[i],
              obscure: !_visible,
              isValid: _validationStatus[i],
              isChecking: _checkingRow[i] ?? false,
              onCheck: () => _validateSingleKey(i),
              onChanged: () => _onTextChange(i),
              onDelete: _removeRow,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: _saving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.surface,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Memeriksa Validitas Key…'),
                    ],
                  )
                : const Text('Simpan API Keys'),
          ),
        ],
      ),
    );
  }
}
