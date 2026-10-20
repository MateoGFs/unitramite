import '../models/assistant_answer.dart';
import '../models/source_ref.dart';
import 'assistant_service.dart';

/// Servicio simulado para probar la interfaz. Se reemplazará por el real.
/// - Si la pregunta contiene "error": simula un fallo de conexión.
/// - Si contiene "inexistente": simula que no hay información.
class MockAssistantService implements AssistantService {
  @override
  Future<AssistantAnswer> ask(String question) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final q = question.toLowerCase();

    if (q.contains('error')) {
      throw const AssistantException(
        'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.',
      );
    }

    if (q.contains('inexistente')) {
      return const AssistantAnswer(
        text: 'No encontré información en los documentos oficiales sobre '
            'ese trámite. Te recomiendo consultar directamente la '
            'dependencia correspondiente de la Universidad de Nariño.',
        found: false,
      );
    }

    return const AssistantAnswer(
      text: 'Esta es una respuesta SIMULADA para probar la interfaz. '
          'Cuando conectemos el backend, aquí aparecerá la respuesta real '
          'basada en los documentos oficiales.',
      sources: [
        SourceRef(documentName: 'Documento de ejemplo (simulado)', page: 1),
      ],
    );
  }
}