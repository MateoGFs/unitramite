import '../models/conversation.dart';

/// Dónde se guardan las conversaciones.
abstract class ConversationStore {
  Future<List<Conversation>> load();
  Future<void> save(List<Conversation> conversations);
}