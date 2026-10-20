import 'source_ref.dart';

enum MessageRole { user, assistant }

/// normal: respuesta con respaldo. notFound: sin información en los
/// documentos. error: falló la comunicación o el procesamiento.
enum MessageStatus { normal, notFound, error }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.role,
    this.sources = const [],
    this.status = MessageStatus.normal,
  });

  final String text;
  final MessageRole role;
  final List<SourceRef> sources;
  final MessageStatus status;
}