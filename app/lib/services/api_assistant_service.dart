import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/assistant_answer.dart';
import '../models/source_ref.dart';
import 'assistant_service.dart';

/// Servicio real: consulta al backend FastAPI.
class ApiAssistantService implements AssistantService {
  ApiAssistantService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Extrae el mensaje de error que envía el backend (campo "detail").
  String _errorMessage(http.Response response) {
    const fallback =
        'El servidor no pudo procesar tu pregunta. '
        'Intenta de nuevo en un momento.';
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic> && data['detail'] is String) {
        return data['detail'] as String;
      }
    } catch (_) {
      // Si no se puede leer, se usa el mensaje genérico.
    }
    return fallback;
  }

  @override
  Future<AssistantAnswer> ask(String question) async {
    final uri = Uri.parse('$_baseUrl/ask');

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'question': question}),
          )
          .timeout(AppConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw AssistantException(_errorMessage(response));
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final sources = (data['sources'] as List<dynamic>? ?? []).map((item) {
        final map = item as Map<String, dynamic>;
        return SourceRef(
          documentName: map['document_name'] as String,
          page: map['page'] as int?,
          url: map['url'] as String?,
        );
      }).toList();

      return AssistantAnswer(
        text: data['answer'] as String,
        sources: sources,
        found: data['found'] as bool? ?? true,
      );
    } on TimeoutException {
      throw const AssistantException(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const AssistantException(
        'No se pudo conectar con el servidor. '
        'Revisa tu conexión e intenta de nuevo.',
      );
    } on FormatException {
      throw const AssistantException(
        'Recibí una respuesta que no pude interpretar. Intenta de nuevo.',
      );
    }
  }
}
