import '../models/assistant_answer.dart';
import '../models/chat_message.dart';

abstract class AssistantService {
  /// [history] son los mensajes anteriores de la conversación, sin la
  /// pregunta actual. Sirven para entender preguntas de seguimiento.
  Future<AssistantAnswer> ask(
    String question, {
    List<ChatMessage> history = const [],
  });
}

/// Error esperado con un mensaje que se puede mostrar al usuario.
class AssistantException implements Exception {
  const AssistantException(this.message);

  final String message;

  @override
  String toString() => message;
}