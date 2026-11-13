import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tramite.dart';
import '../providers/tramites_provider.dart';
import '../services/tramites_service.dart';
import '../widgets/rich_message.dart';
import '../widgets/source_link.dart';
import 'assistant_screen.dart';
import '../models/tramite_progress.dart';
import '../providers/progress_provider.dart';

class TramiteDetailScreen extends StatefulWidget {
  const TramiteDetailScreen({super.key, required this.tramiteId});

  final String tramiteId;

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  late Future<TramiteDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<TramiteDetail> _load() =>
      context.read<TramitesProvider>().detail(widget.tramiteId);

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trámite')),
      body: FutureBuilder<TramiteDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is TramitesException
                ? error.message
                : 'No se pudo cargar el trámite. Intenta de nuevo.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _retry,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _DetailBody(detail: snapshot.data!);
        },
      ),
    );
  }
}

String _formatDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final TramiteDetail detail;

  void _ask(BuildContext context, String question) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssistantScreen(initialQuestion: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final progress = context.watch<ProgressProvider>();
    final tracking = progress.byId(detail.id);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(detail.nombre, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text(detail.categoria)),
                if (detail.fechaVerificacion.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.verified_outlined, size: 18),
                    label: Text(
                      'Verificado el ${_formatDate(detail.fechaVerificacion)}',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(detail.descripcion, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _ask(
                context,
                '¿Cómo realizo el trámite de ${detail.nombre}?',
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Preguntar al asistente'),
            ),
            const SizedBox(height: 8),
            if (tracking == null)
              OutlinedButton.icon(
                onPressed: detail.pasos.isEmpty
                    ? null
                    : () => context.read<ProgressProvider>().start(detail),
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Iniciar este trámite'),
              )
            else
              _TrackingCard(
                progress: tracking,
                total: detail.pasos.length,
                onStop: () =>
                    context.read<ProgressProvider>().remove(detail.id),
              ),
            if (detail.requisitos.isNotEmpty)
              _Section(
                title: 'Requisitos',
                children: [_BulletList(items: detail.requisitos)],
              ),
            if (detail.pasos.isNotEmpty)
              _Section(
                title: 'Pasos',
                children: [
                  _StepList(
                    items: detail.pasos,
                    checked: tracking?.completed,
                    onToggle: tracking == null
                        ? null
                        : (index) => context
                            .read<ProgressProvider>()
                            .toggleStep(detail.id, index),
                  ),
                ],
              ),
            if (detail.condiciones.isNotEmpty)
              _Section(
                title: 'Condiciones importantes',
                children: [_BulletList(items: detail.condiciones)],
              ),
            if (detail.referencia.isNotEmpty)
              _Section(
                title: 'Información de referencia',
                children: [
                  Card(
                    color: scheme.tertiaryContainer,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BulletList(
                            items: detail.referencia,
                            color: scheme.onTertiaryContainer,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estos datos pueden cambiar: verifícalos antes de '
                            'pagar o presentar la solicitud.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            if (detail.dependencia.isNotEmpty)
              _Section(
                title: 'Dependencia responsable',
                children: [
                  Text(detail.dependencia, style: theme.textTheme.bodyMedium),
                  if (detail.contacto.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SelectableText(
                      'Contacto: ${detail.contacto}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            if (detail.fuentes.isNotEmpty)
              _Section(
                title: 'Fuentes oficiales',
                children: [
                  for (final source in detail.fuentes)
                    SourceLink(
                      source: source,
                      color: scheme.primary,
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            if (detail.preguntas.isNotEmpty)
              _Section(
                title: 'Preguntas que puedes hacerle al asistente',
                children: [
                  for (final question in detail.preguntas)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.chat_bubble_outline, size: 20),
                      title: Text(question),
                      onTap: () => _ask(context, question),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items, this.color});

  final List<String> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(color: color);
    final linkColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: style),
                Expanded(
                  child: RichMessage(
                    text: item,
                    style: style,
                    linkColor: linkColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.items, this.checked, this.onToggle});

  final List<String> items;

  /// Pasos marcados. Si es null, no hay seguimiento y se muestran números.
  final Set<int>? checked;
  final ValueChanged<int>? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracking = checked != null && onToggle != null;

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tracking)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: checked!.contains(i),
                      onChanged: (_) => onToggle!(i),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 12,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichMessage(
                    text: items[i],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tracking && checked!.contains(i)
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                      decoration: tracking && checked!.contains(i)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    linkColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.progress,
    required this.total,
    required this.onStop,
  });

  final TramiteProgress progress;
  final int total;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = progress.completed.where((i) => i < total).length;
    final finished = total > 0 && done >= total;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  finished ? Icons.check_circle : Icons.timelapse,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    finished
                        ? '¡Trámite completado!'
                        : 'Tu avance: $done de $total pasos',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: total == 0 ? 0 : done / total),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onStop,
                child: const Text('Dejar de seguir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}