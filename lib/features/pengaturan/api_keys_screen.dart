library;

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/round_back_button.dart';
import 'api_keys_card.dart';

/// Sub-layar API Key Gemini — key disembunyikan dari halaman Pengaturan
/// utama (masuk halaman khusus biar aman, MASTER_SPEC §6).
class ApiKeysScreen extends StatelessWidget {
  const ApiKeysScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      RoundBackButton(onTap: onBack),
                      const SizedBox(width: 12),
                      const Text(
                        'API Key Gemini',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 52),
                    child: Text(
                      'Key disembunyikan otomatis & dikunci di halaman '
                      'khusus — aman saat app terbuka di depan orang.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ApiKeysCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
