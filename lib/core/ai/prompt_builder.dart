/// Prompt & response-schema terkunci (ARCHITECTURE.md §4.3, MASTER_SPEC §4.2).
library;

const geminiModel = 'gemini-3.5-flash-lite';

/// System prompt: ubah input jadi daftar tugas + aturan pemetaan.
const systemPrompt =
    'Kamu parser tugas personal & akademik cerdas KwakTodo. Ubah input user (teks, suara, atau foto/screenshot tugas) '
    'menjadi daftar tugas terstruktur dengan bahasa yang sama seperti input (default: Bahasa Indonesia). '
    'Aturan: '
    '1. Title: Buat judul yang jelas & ringkas. Jika dari portal akademik / LMS / e-class / modul kuliah, sertakan kode MK dan nama tugasnya (contoh: "[PR5003] Praktikum Basis Data - Homeact 08"). '
    '2. Deadline: Parse tanggal dan jam deadline ke format ISO8601 lokal (YYYY-MM-DDTHH:mm:ss). Kenali format tanggal Indonesia seperti "06 November 2026 23:59 WIB" -> "2026-11-06T23:59:00". '
    '3. Prioritas: kata tinggi/urgent/high/mendesak = high, santai/ringan/low = low, selain itu medium. '
    '4. Kategori: kuliah/tugas/praktikum/ujian/laporan/e-class/kuliah = akademik; pribadi/rumah/belanja/kesehatan = personal; organisasi/kepanitiaan/rapat/divisi = organisasi; selain itu lainnya. '
    '5. Notes: Masukkan instruksi penting seperti format file yang diizinkan (pdf, docx, zip), link pengumpulan, atau catatan instruktur. '
    'Bila tidak yakin, isi title saja dan field lain null. Jangan mengarang tugas yang tidak ada pada input.';

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
