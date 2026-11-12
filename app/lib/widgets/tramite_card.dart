import 'package:flutter/material.dart';

import '../models/tramite.dart';

/// Tarjeta de un trámite en la lista de la pantalla de inicio.
class TramiteCard extends StatelessWidget {
  const TramiteCard({super.key, required this.tramite, required this.onTap});

  final TramiteSummary tramite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tramite.nombre, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      tramite.descripcion,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}