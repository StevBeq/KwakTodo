library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';

/// Mode input "Tanya AI" (PRD FR-2) + TaskSource ekivalen (SCHEMA §2).
enum AiMode { voice, text, photo }

extension AiModeX on AiMode {
  TaskSource get source => switch (this) {
    AiMode.voice => TaskSource.aiVoice,
    AiMode.text => TaskSource.aiText,
    AiMode.photo => TaskSource.aiPhoto,
  };

  String get label => switch (this) {
    AiMode.voice => 'Voice',
    AiMode.text => 'Teks',
    AiMode.photo => 'Foto',
  };

  IconData get icon => switch (this) {
    AiMode.voice => Icons.mic_rounded,
    AiMode.text => Icons.keyboard_outlined,
    AiMode.photo => Icons.camera_alt_outlined,
  };
}
