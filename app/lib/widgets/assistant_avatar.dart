import 'package:flutter/material.dart';

import 'seal_mark.dart';

/// Avatar del asistente: el sello sobre fondo de tinta.
class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: const SealMark(size: 18, color: Colors.white, strokeWidth: 1.4),
    );
  }
}