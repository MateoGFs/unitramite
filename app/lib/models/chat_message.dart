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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      status: MessageStatus.values.byName(json['status'] as String),
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((e) => SourceRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String text;
  final MessageRole role;
  final List<SourceRef> sources;
  final MessageStatus status;

  Map<String, dynamic> toJson() => {
        'text': text,
        'role': role.name,
        'status': status.name,
        'sources': sources.map((s) => s.toJson()).toList(),
      };
}