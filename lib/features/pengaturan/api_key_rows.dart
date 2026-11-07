library;

import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Baris satu API key: label "Key N", input tersamar, ikon status
/// validasi online, dan tombol hapus. Dipisah dari kartu agar file
/// tetap ≤ 300 baris (RULES).
class KeyRow extends StatelessWidget {
  const KeyRow({
    super.key,
    required this.index,
    required this.controller,
    required this.obscure,
    required this.isValid,
    required this.isChecking,
    required this.onCheck,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final TextEditingController controller;
  final bool obscure;
  final bool? isValid;
  final bool isChecking;
  final VoidCallback onCheck;
  final VoidCallback onChanged;
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
            enableInteractiveSelection: true,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onCheck(),
            decoration: InputDecoration(
              hintText: 'masukkan API key…',
              suffixIcon: _buildStatusSuffix(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        DeleteKeyButton(onTap: () => onDelete(index)),
      ],
    );
  }

  Widget? _buildStatusSuffix() {
    if (isChecking) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }
    if (isValid == true) {
      return const Tooltip(
        message: 'Key Valid & Aktif',
        child: Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: AppColors.success,
        ),
      );
    }
    if (isValid == false) {
      return const Tooltip(
        message: 'Key Tidak Valid',
        child: Icon(Icons.cancel_rounded, size: 18, color: AppColors.danger),
      );
    }
    return Tooltip(
      message: 'Cek validitas key',
      child: IconButton(
        icon: const Icon(
          Icons.verified_outlined,
          size: 18,
          color: AppColors.muted,
        ),
        onPressed: onCheck,
      ),
    );
  }
}

/// Tombol hapus lingkaran merah kecil di ujung baris key.
class DeleteKeyButton extends StatelessWidget {
  const DeleteKeyButton({super.key, required this.onTap});

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
