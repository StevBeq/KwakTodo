library;

import 'dart:convert' show base64Encode, jsonDecode, jsonEncode, utf8;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;

import 'ai_result.dart';
import 'key_rotator.dart';
import 'prompt_builder.dart';
import 'task_draft_json.dart';
import '../domain/models.dart';

/// GeminiService — ARCHITECTURE.md §4.3: teks/gambar → generateContent REST
/// (structured output) → `Result<List<TaskDraft>>`. google_generative_ai
/// deprecated → REST + http; rotasi key FR-10 di sini.
class GeminiService {
  GeminiService({required List<String> Function() keys})
    : rotator = KeyRotator(keys);

  final KeyRotator rotator;
  final http.Client _http = http.Client();

  /// Dipakai tests untuk injeksi transport palsu.
  @visibleForTesting
  Future<Result<List<TaskDraft>>> send(
    List<Map<String, dynamic>> parts,
  ) async => rotator.run((key) async {
    final http.Response resp;
    try {
      resp = await _http.post(
        Uri.https(
          'generativelanguage.googleapis.com',
          '/v1beta/models/$geminiModel:generateContent',
        ),
        headers: {'x-goog-api-key': key, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'contents': [
            {'role': 'user', 'parts': parts},
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseJsonSchema': responseJsonSchema,
          },
        }),
      );
    } on http.ClientException {
      return Result.err(
        const AppError(
          kind: AppErrorKind.network,
          message: 'Butuh internet untuk pakai AI — cek koneksi.',
        ),
      );
    }

    if (resp.statusCode == 429) {
      return Result.err(
        const AppError(
          kind: AppErrorKind.quota,
          message: 'Key ini kena limit — coba key berikutnya…',
        ),
      );
    }

    final body =
        jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      return Result.err(
        AppError(
          kind: AppErrorKind.parse,
          message:
              'Gemini menolak permintaan (${resp.statusCode}) — '
              'cek API key di Pengaturan.',
          cause: body['error'],
        ),
      );
    }

    final tasks = _extractTasks(body);
    if (tasks == null) {
      return Result.err(
        const AppError(
          kind: AppErrorKind.parse,
          message: 'Gagal membaca hasil AI — coba lagi.',
        ),
      );
    }
    return Result.ok(tasks);
  });

  Future<Result<List<TaskDraft>>> parseText(String text) => send([
    {'text': text},
  ]);

  Future<Result<List<TaskDraft>>> parseImage(List<int> bytes) => send([
    {
      'inline_data': {'mime_type': 'image/jpeg', 'data': base64Encode(bytes)},
    },
  ]);

  /// tasks dari response.generateContent: bila json tak terbaca (error/
  /// safety block) kembalikan null (ARCH §5: parse).
  List<TaskDraft>? _extractTasks(Map<String, dynamic> body) {
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = (candidates.first as Map?)?['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) return null;
    final text = (parts.first as Map)['text'];
    if (text is String) {
      return tasksFromJson(jsonDecode(text) as Map<String, dynamic>);
    }
    return null;
  }
}
