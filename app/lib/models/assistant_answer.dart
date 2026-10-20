import 'source_ref.dart';

/// Lo que devuelve el servicio del asistente a la app.
class AssistantAnswer {
  const AssistantAnswer({
    required this.text,
    this.sources = const [],
    this.found = true,
  });

  final String text;
  final List<SourceRef> sources;

  /// false cuando no hay documentos que respalden la respuesta.
  final bool found;
}