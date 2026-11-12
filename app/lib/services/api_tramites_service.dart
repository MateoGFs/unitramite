import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/tramite.dart';
import 'tramites_service.dart';

/// Consulta el catálogo de trámites al backend.
class ApiTramitesService implements TramitesService {
  ApiTramitesService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response =
          await _client.get(uri).timeout(AppConstants.catalogTimeout);
      if (response.statusCode == 404) {
        throw const TramitesException('No se encontró ese trámite.');
      }
      if (response.statusCode != 200) {
        throw const TramitesException(
          'No se pudo cargar la información de los trámites. '
          'Intenta de nuevo.',
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const TramitesException(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const TramitesException(
        'No se pudo conectar con el servidor. '
        'Revisa tu conexión e intenta de nuevo.',
      );
    } on FormatException {
      throw const TramitesException(
        'Recibí una respuesta que no pude interpretar. Intenta de nuevo.',
      );
    }
  }

  @override
  Future<List<TramiteSummary>> list() async {
    final data = await _get('/tramites');
    return (data as List<dynamic>)
        .map((item) => TramiteSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TramiteDetail> detail(String id) async {
    final data = await _get('/tramites/$id');
    return TramiteDetail.fromJson(data as Map<String, dynamic>);
  }
}