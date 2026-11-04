library;

import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import 'ai_mode.dart';

/// Header sheet "Tanya AI" (prototype 309–312): blok icon accent + judul +
/// sub model info "hasil bisa diedit".
class CaptureHead extends StatelessWidget {
  const CaptureHead({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 18,
            color: AppColors.surface,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanya AI',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                'gemini-3.5-flash-lite · hasil bisa diedit',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Segmen 3 tab mode (prototype 313–317): track krem, aktif primary putih.
class ModeTabs extends StatelessWidget {
  const ModeTabs({super.key, required this.active, required this.onPick});

  final AiMode active;
  final ValueChanged<AiMode> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.trackCream,
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        children: [
          for (final m in AiMode.values) ...[
            if (m != AiMode.values.first) const SizedBox(width: 4),
            Expanded(
              child: InkWell(
                onTap: () => onPick(m),
                borderRadius: AppRadius.chip,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: m == active ? AppColors.primary : Colors.transparent,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m.icon,
                        size: 14,
                        color: m == active
                            ? AppColors.surface
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        m.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: m == active
                              ? AppColors.surface
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pane voice (prototype 318–323): tombol mic bundar + hint + transkrip.
class VoicePane extends StatelessWidget {
  const VoicePane({
    super.key,
    required this.listening,
    required this.sttHint,
    required this.ctrl,
    required this.onMic,
  });

  final bool listening;
  final String sttHint;
  final TextEditingController ctrl;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onMic,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: listening ? AppColors.danger : AppColors.primary,
            ),
            child: const Icon(
              Icons.mic_rounded,
              size: 30,
              color: AppColors.surface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sttHint,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          minLines: 2,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Teks dari suaramu muncul di sini…',
          ),
        ),
      ],
    );
  }
}

/// Pane teks (prototype 325–327): prompt bebas EN/ID.
class TextPane extends StatelessWidget {
  const TextPane({super.key, required this.ctrl});

  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      minLines: 3,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        hintText:
            "Tulis apa aja: 'besok kumpulin laporan proglan jam 10 tinggi'…",
      ),
    );
  }
}

/// Pane foto (prototype 328–344): 3 sumber + preview thumbnail + nama file.
class PhotoPane extends StatelessWidget {
  const PhotoPane({
    super.key,
    required this.photo,
    required this.onCamera,
    required this.onGallery,
    required this.onFile,
  });

  final ({Uint8List bytes, String name})? photo;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _PhotoSource(
              icon: Icons.camera_alt_outlined,
              label: 'Kamera',
              onTap: onCamera,
            ),
            _PhotoSource(
              icon: Icons.image_outlined,
              label: 'Galeri',
              onTap: onGallery,
            ),
            _PhotoSource(
              icon: Icons.folder_outlined,
              label: 'File',
              onTap: onFile,
            ),
          ],
        ),
        if (photo != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              photo!.bytes,
              height: 96,
              width: double.infinity,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${photo!.name} · siap dikirim (auto-compress)',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class _PhotoSource extends StatelessWidget {
  const _PhotoSource({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.divider, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
