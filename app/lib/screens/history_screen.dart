import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/format.dart';
import '../providers/chat_provider.dart';
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
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aún no tienes conversaciones guardadas.\n\n'
                      'Cada pregunta que le hagas al asistente quedará '
                      'registrada aquí.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final conversation in items)
                          Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              title: Text(
                                conversation.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${formatDateTime(conversation.updatedAt)} · '
                                '${conversation.questionCount} '
                                '${conversation.questionCount == 1 ? 'pregunta' : 'preguntas'}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Eliminar conversación',
                                onPressed: () => chat.delete(conversation.id),
                              ),
                              onTap: () {
                                chat.open(conversation.id);
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const AssistantScreen(),
                                  ),
                                );
                              },
                            ),
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