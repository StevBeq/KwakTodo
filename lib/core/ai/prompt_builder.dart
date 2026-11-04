/// Prompt & response-schema terkunci (ARCHITECTURE.md §4.3, MASTER_SPEC §4.2).
library;

const geminiModel = 'gemini-3.5-flash-lite';

/// System prompt: ubah input jadi daftar tugas + aturan pemetaan.
const systemPrompt =
    'Kamu parser tugas personal. Ubah input user menjadi '
    'daftar tugas dengan bahasa yang sama seperti input (voice = Indonesia). '
    'Aturan: deadline pakai ISO8601 waktu lokal tanpa tanggal riwayat; '
    'prioritas: kata tinggi/urgent/high/mendesak = high, santai/ringan/low '
    '= low, selain itu medium; kategori: kuliah/tugas/ujian/kumpul/progLan '
    '= akademik, pribadi/rumah/belanja = personal, organisasi/rapat/divisi '
    '= organisasi, selain itu lainnya. Bila tidak yakin isi title saja '
    'dan field lain null. Jangan menemukan tugas yang tidak disebut user.';

/// Response schema (structured output, generateContent REST v1beta).
const responseJsonSchema = <String, dynamic>{
  'type': 'object',
  'required': ['tasks'],
  'properties': {
    'tasks': {
      'type': 'array',
      'items': {
        'type': 'object',
        'required': ['title'],
        'properties': {
          'title': {'type': 'string'},
          // nullable: boolean per-field (format Gemini structured output).
          'deadline': {'type': 'string', 'nullable': true},
          'priority': {'type': 'string', 'nullable': true},
          'category': {'type': 'string', 'nullable': true},
          'notes': {'type': 'string', 'nullable': true},
        },
      },
    },
  },
};
