import 'package:flutter/material.dart';

/// Tarjeta de una respuesta del asistente. El borde izquierdo indica su estado.
class AssistantSurface extends StatelessWidget {
  const AssistantSurface({super.key, required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}