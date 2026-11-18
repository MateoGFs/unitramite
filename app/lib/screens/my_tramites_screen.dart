import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/format.dart';
import '../core/utils/tramite_icons.dart';
import '../models/tramite_progress.dart';
import '../providers/progress_provider.dart';
import '../widgets/state_message.dart';
import 'tramite_detail_screen.dart';

class MyTramitesScreen extends StatelessWidget {
  const MyTramitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis trámites')),
      body: Consumer<ProgressProvider>(
        builder: (context, progress, _) {
          final items = progress.items;

          if (items.isEmpty) {
            return const StateMessage(
              icon: Icons.checklist,
              title: 'Aún no sigues ningún trámite',
              message: 'Abre un trámite y pulsa «Iniciar este trámite» '
                  'para marcar los pasos que ya hiciste.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final item in items) _ProgressCard(item: item),
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
  const _ProgressCard({required this.item});

  final TramiteProgress item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TramiteDetailScreen(tramiteId: item.tramiteId),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tramiteIcon(item.tramiteId),
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nombre, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: item.fraction,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      if (item.isDone)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text('Completado', style: theme.textTheme.bodyMedium),
                          ],
                        )
                      else
                        Text(
                          '${item.completedCount} de ${item.totalSteps} pasos',
                          style: theme.textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        'Actualizado el ${formatDate(item.updatedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Dejar de seguir',
                  onPressed: () =>
                      context.read<ProgressProvider>().remove(item.tramiteId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}