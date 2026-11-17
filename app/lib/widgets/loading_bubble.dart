import 'package:flutter/material.dart';

import 'assistant_avatar.dart';
import 'assistant_surface.dart';
import 'typing_dots.dart';

/// Se muestra mientras el asistente busca la respuesta.
class LoadingBubble extends StatelessWidget {
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AssistantAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: AssistantSurface(
              accent: scheme.primary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TypingDots(color: scheme.primary),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Buscando en los trámites verificados…',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}