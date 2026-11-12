import 'package:flutter/material.dart';

import '../core/utils/open_link.dart';
import '../models/source_ref.dart';

/// Línea de fuente que abre el documento oficial al tocarla.
class SourceLink extends StatelessWidget {
  const SourceLink({
    super.key,
    required this.source,
    required this.color,
    required this.style,
  });

  final SourceRef source;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final url = source.url;
    final label = Text(
      '• ${source.label}',
      style: style?.copyWith(
        color: color,
        decoration: url != null ? TextDecoration.underline : null,
        decorationColor: color,
      ),
    );

    if (url == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: label,
      );
    }

    return InkWell(
      onTap: () => openLink(context, url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: label,
      ),
    );
  }
}