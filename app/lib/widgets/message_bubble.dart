import 'package:flutter/material.dart';

import 'source_link.dart';
import '../models/chat_message.dart';

import 'rich_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isUser = message.role == MessageRole.user;

    final Color background;
    final Color foreground;
    if (isUser) {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (message.status == MessageStatus.error) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else if (message.status == MessageStatus.notFound) {
      background = scheme.tertiaryContainer;
      foreground = scheme.onTertiaryContainer;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurface;
    }

    final linkColor =
        message.status == MessageStatus.normal && !isUser
            ? scheme.primary
            : foreground;
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(color: foreground);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: foreground,
      fontWeight: FontWeight.bold,
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isUser)
                SelectableText(message.text, style: bodyStyle)
              else
                RichMessage(
                  text: message.text,
                  style: bodyStyle,
                  linkColor: linkColor,
                ),
              if (message.sources.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Fuentes consultadas', style: labelStyle),
                const SizedBox(height: 4),
                for (final source in message.sources)
                  SourceLink(
                    source: source,
                    color: linkColor,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

