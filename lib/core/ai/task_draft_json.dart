library;

import '../../core/domain/models.dart';

/// Decoding JSON hasil Gemini → `List<TaskDraft>` — FUNGSI MURNI (mudah
/// di-test, MASTER_SPEC §6). Aturan SCHEMA §8:
/// - title wajib non-kosong (skip bila kosong);
/// - priority/category di luar enum → null (fallback form), jangan crash;
/// - deadline ISO8601 lokal/null/tak-valid → null.
List<TaskDraft> tasksFromJson(Map<String, dynamic> json) {
  final rawTasks = json['tasks'];
  if (rawTasks is! List) return const [];
  return [
    for (final t in rawTasks)
      if (t is Map && _nonEmpty(t['title']))
        TaskDraft(
          title: (t['title'] as String).trim(),
          deadline: _parseDate(t['deadline']),
          priority: _parsePriority(t['priority']),
          category: _parseCategory(t['category']),
          notes: _nonEmpty(t['notes']) ? (t['notes'] as String).trim() : null,
        ),
  ];
}

bool _nonEmpty(Object? v) => v is String && v.trim().isNotEmpty;

String? _asStr(Object? v) =>
    v is String && v.trim().isNotEmpty ? v.trim() : null;

DateTime? _parseDate(Object? v) {
  final s = _asStr(v);
  return s == null ? null : DateTime.tryParse(s)?.toLocal();
}

Priority? _parsePriority(Object? v) => switch (_asStr(v)?.toLowerCase()) {
  'high' => Priority.high,
  'medium' => Priority.medium,
  'low' => Priority.low,
  _ => null,
};

Category? _parseCategory(Object? v) => switch (_asStr(v)?.toLowerCase()) {
  'akademik' => Category.akademik,
  'personal' => Category.personal,
  'organisasi' => Category.organisasi,
  'lainnya' => Category.lainnya,
  _ => null,
};
