library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/domain/models.dart';
import '../../shared/providers/task_provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/toast.dart';
import 'form_fields.dart';

/// TaskFormSheet add/edit/review-AI — DESIGN.md §5: title, deadline,
/// prioritas, kategori chips, notes; tombol Batal/Buang + Tambahkan.
/// Kontrak field: SCHEMA §2. Mode review (draft.AI) = header berbeda,
/// tombol "Acc & Tambahkan", source = task source dari mode input (FR-3).
class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.initial}) : draft = null, source = null;

  const TaskFormSheet.review({
    super.key,
    required this.draft,
    TaskSource? source,
  }) : initial = null,
       source = source ?? TaskSource.manual;

  final Task? initial;

  /// Draf hasil parsing AI — bila ada: mode review (FR-3).
  final TaskDraft? draft;

  /// Source task ketika review di-acc (ai_voice/ai_text/ai_photo).
  final TaskSource? source;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initial?.title ?? widget.draft?.title ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.initial?.notes ?? widget.draft?.notes ?? '',
  );
  late DateTime? _deadline = widget.initial?.deadline ?? widget.draft?.deadline;
  late Priority _priority =
      widget.initial?.priority ?? widget.draft?.priority ?? Priority.medium;
  late Category _category =
      widget.initial?.category ?? widget.draft?.category ?? Category.akademik;
  bool _saving = false;

  bool get _editing => widget.initial != null;
  bool get _reviewing => widget.draft != null;
  String get _headerTitle {
    if (_editing) return 'Edit Tugas';
    if (_reviewing) return 'Review Hasil AI';
    return 'Tugas Baru';
  }

  String get _headerSub {
    if (_editing) return 'Ubah detail tugasnya.';
    if (_reviewing) {
      return 'Cek hasil parsing — benahi bila ada yang salah.';
    }
    return 'Isi detail tugasnya.';
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      showAppToast(context, 'Judulnya diisi dulu ✋');
      return;
    }
    final notes = _notes.text.trim();

    setState(() => _saving = true);
    try {
      final provider = context.read<TaskProvider>();
      if (_editing) {
        await provider.edit(
          widget.initial!,
          title: title,
          deadline: _deadline,
          priority: _priority,
          category: _category,
          notes: notes.isEmpty ? null : notes,
        );
        if (mounted) Navigator.of(context).pop(true);
        if (mounted) showAppToast(context, 'Perubahan disimpan ✏️');
      } else {
        await provider.add(
          title: title,
          deadline: _deadline,
          priority: _priority,
          category: _category,
          notes: notes.isEmpty ? null : notes,
          source: widget.source ?? TaskSource.manual,
        );
        if (mounted) Navigator.of(context).pop(true);
        if (mounted) showAppToast(context, 'Tugas ditambahkan! 🎉');
      }
    } on ArgumentError catch (e) {
      if (mounted) showAppToast(context, e.message.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sheet,
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.grabber,
              borderRadius: AppRadius.chip,
            ),
          ),
          Row(
            children: [
              Icon(
                _editing
                    ? Icons.edit
                    : _reviewing
                    ? Icons.auto_awesome
                    : Icons.edit_document,
                size: 18,
                color: _reviewing ? AppColors.accent : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _headerTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_reviewing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    switch (widget.source) {
                      TaskSource.aiVoice => 'AI Voice',
                      TaskSource.aiText => 'AI Teks',
                      TaskSource.aiPhoto => 'AI Foto',
                      _ => 'AI',
                    },
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _headerSub,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          const Text(
            'JUDUL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            identifier: 'task_title_input',
            textField: true,
            label: 'Judul tugas',
            child: TextField(
              controller: _title,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DeadlineField(
                  value: _deadline,
                  onChanged: (d) => setState(() => _deadline = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PriorityField(
                  value: _priority,
                  onChanged: (p) => setState(() => _priority = p),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'KATEGORI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          CategoryChipRow(
            value: _category,
            onChanged: (c) => setState(() => _category = c),
          ),
          const SizedBox(height: 12),
          const Text(
            'CATATAN / DESKRIPSI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            identifier: 'task_notes_input',
            textField: true,
            label: 'Catatan tugas',
            child: TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Detail lengkap, link, format pengumpulan…',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  identifier: 'task_cancel_btn',
                  button: true,
                  child: OutlinedButton(
                    onPressed: Navigator.of(context).pop,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.borderSoft,
                        width: 2,
                      ),
                      foregroundColor: AppColors.muted,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(_reviewing ? 'Buang' : 'Batal'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  identifier: 'task_submit_btn',
                  button: true,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(
                      _editing
                          ? 'Simpan'
                          : _reviewing
                          ? 'Acc & Tambahkan'
                          : 'Tambahkan',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }
}
