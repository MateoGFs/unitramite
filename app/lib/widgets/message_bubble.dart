import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import 'assistant_avatar.dart';
import 'assistant_surface.dart';
import 'rich_message.dart';
import 'source_link.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.role == MessageRole.user) {
      return _UserBubble(text: message.text);
    }
    return _AssistantBubble(message: message);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: const EdgeInsets.only(top: 14, bottom: 6, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: SelectableText(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // El color del borde izquierdo comunica el estado de la respuesta.
    final accent = switch (message.status) {
      MessageStatus.normal => scheme.primary,
      MessageStatus.notFound => scheme.tertiary,
      MessageStatus.error => scheme.error,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AssistantAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AssistantSurface(
                accent: accent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichMessage(
                      text: message.text,
                      style: theme.textTheme.bodyMedium,
                      linkColor: scheme.primary,
                    ),
                    if (message.sources.isNotEmpty) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Fuentes oficiales',
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      for (final source in message.sources)
                        SourceLink(
                          source: source,
                          color: scheme.primary,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}