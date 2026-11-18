import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/format.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../widgets/state_message.dart';
import 'assistant_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final chat = context.read<ChatProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text(
          'Se eliminarán todas las conversaciones guardadas en este '
          'dispositivo. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await chat.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        final items = chat.history;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Historial'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Borrar todo',
                onPressed: items.isEmpty || chat.isLoading
                    ? null
                    : () => _confirmClear(context),
              ),
            ],
          ),
          body: items.isEmpty
              ? const StateMessage(
                  icon: Icons.history,
                  title: 'Aún no hay conversaciones',
                  message: 'Cada pregunta que le hagas al asistente '
                      'quedará guardada aquí.',
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        for (final conversation in items)
                          _ConversationCard(
                            conversation: conversation,
                            onOpen: () {
                              chat.open(conversation.id);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AssistantScreen(),
                                ),
                              );
                            },
                            onDelete: () => chat.delete(conversation.id),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.onOpen,
    required this.onDelete,
  });

  final Conversation conversation;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = conversation.questionCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count ${count == 1 ? 'pregunta' : 'preguntas'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        formatDateTime(conversation.updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar conversación',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}