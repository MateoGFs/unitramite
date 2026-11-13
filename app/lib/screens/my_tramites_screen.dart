import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tramite_progress.dart';
import '../providers/progress_provider.dart';
import 'tramite_detail_screen.dart';

class MyTramitesScreen extends StatelessWidget {
  const MyTramitesScreen({super.key});

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis trámites')),
      body: Consumer<ProgressProvider>(
        builder: (context, progress, _) {
          final items = progress.items;

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no sigues ningún trámite.\n\n'
                  'Abre un trámite y pulsa «Iniciar este trámite» para ir '
                  'marcando los pasos que ya hiciste.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final item in items)
                    _ProgressCard(
                      item: item,
                      updated: _formatDate(item.updatedAt),
                      theme: theme,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.item,
    required this.updated,
    required this.theme,
  });

  final TramiteProgress item;
  final String updated;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TramiteDetailScreen(tramiteId: item.tramiteId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.nombre, style: theme.textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Dejar de seguir',
                    onPressed: () => context
                        .read<ProgressProvider>()
                        .remove(item.tramiteId),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: LinearProgressIndicator(value: item.fraction),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item.isDone) ...[
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    const Text('Completado'),
                  ] else
                    Text(
                      '${item.completedCount} de ${item.totalSteps} pasos',
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      'Actualizado el $updated',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}