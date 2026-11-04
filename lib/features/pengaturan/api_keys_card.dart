library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/providers/settings_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/toast.dart';

/// Kartu API Key Gemini — prototype (211–220, 596–606): judul + tombol
/// Tambah, deskripsi fallback key, baris "Key N" + input + hapus,
/// tombol Simpan API Keys (flutter_secure_storage, MASTER_SPEC §6).
class ApiKeysCard extends StatefulWidget {
  const ApiKeysCard({super.key});

  @override
  State<ApiKeysCard> createState() => _ApiKeysCardState();
}

class _ApiKeysCardState extends State<ApiKeysCard> {
  List<TextEditingController> _controllers = [];

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
    setState(
      () =>
          _controllers = [for (final k in keys) TextEditingController(text: k)],
    );
  }

  void _addRow() => setState(() {
    _controllers.add(TextEditingController());
  });

  void _removeRow(int i) => setState(() {
    _controllers.removeAt(i).dispose();
  });

  Future<void> _save() async {
    final keys = _controllers.map((c) => c.text.trim()).toList();
    final filled = keys.where((k) => k.isNotEmpty).length;
    if (filled == 0) {
      showAppToast(context, 'Belum ada key yang diisi');
      return;
    }
    await context.read<SettingsProvider>().saveApiKeys(keys);
    if (!mounted) return;
    // Rebuild controller dari versi yang sudah di-trim.
    _rebuild([for (final t in keys) t]);
    showAppToast(context, '$filled API key tersimpan (secure storage) 🔐');
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
            'Key 1 limit → app otomatis pakai key 2, dst. Variasikan dari '
            'akun Google berbeda biar free tier dobel.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _controllers.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _KeyRow(
              index: i,
              controller: _controllers[i],
              obscure: !_visible,
              onDelete: _removeRow,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Simpan API Keys'),
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({
    required this.index,
    required this.controller,
    required this.obscure,
    required this.onDelete,
  });

  final int index;
  final TextEditingController controller;
  final bool obscure;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            'Key ${index + 1}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            // Boleh copy walau tersamar (paste ke form lain saat ganti HP).
            enableInteractiveSelection: true,
            decoration: const InputDecoration(hintText: 'masukkan API key…'),
          ),
        ),
        const SizedBox(width: 8),
        _DeleteKeyButton(onTap: () => onDelete(index)),
      ],
    );
  }
}

class _DeleteKeyButton extends StatelessWidget {
  const _DeleteKeyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.delete_outline_rounded,
            size: 14,
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }
}
