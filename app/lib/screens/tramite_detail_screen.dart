import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/tramite_icons.dart';
import '../models/tramite.dart';
import '../models/tramite_progress.dart';
import '../providers/progress_provider.dart';
import '../providers/tramites_provider.dart';
import '../services/tramites_service.dart';
import '../widgets/rich_message.dart';
import '../widgets/seal_mark.dart';
import '../widgets/source_link.dart';
import '../widgets/state_message.dart';
import 'assistant_screen.dart';

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

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

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
            return StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'No se pudo cargar el trámite',
              message: error is TramitesException
                  ? error.message
                  : 'Intenta de nuevo en un momento.',
              actionLabel: 'Reintentar',
              onAction: _retry,
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _Hero(detail: detail),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => _ask(
                    context,
                    '¿Cómo realizo el trámite de ${detail.nombre}?',
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Preguntar al asistente'),
                ),
                if (tracking == null)
                  OutlinedButton.icon(
                    onPressed: detail.pasos.isEmpty
                        ? null
                        : () => context.read<ProgressProvider>().start(detail),
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('Iniciar este trámite'),
                  ),
              ],
            ),
            if (tracking != null) ...[
              const SizedBox(height: 14),
              _TrackingCard(
                progress: tracking,
                total: detail.pasos.length,
                onStop: () =>
                    context.read<ProgressProvider>().remove(detail.id),
              ),
            ],
            if (detail.requisitos.isNotEmpty)
              _Section(
                icon: Icons.fact_check_outlined,
                title: 'Requisitos',
                children: [_BulletList(items: detail.requisitos)],
              ),
            if (detail.pasos.isNotEmpty)
              _Section(
                icon: Icons.route_outlined,
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
                icon: Icons.info_outline,
                title: 'Condiciones importantes',
                children: [_BulletList(items: detail.condiciones)],
              ),
            if (detail.referencia.isNotEmpty)
              _Section(
                icon: Icons.sell_outlined,
                title: 'Información de referencia',
                children: [
                  Card(
                    color: scheme.tertiaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: scheme.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BulletList(
                            items: detail.referencia,
                            color: scheme.onTertiaryContainer,
                          ),
                          const SizedBox(height: 6),
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
                icon: Icons.apartment_outlined,
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
                icon: Icons.verified_outlined,
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
                icon: Icons.forum_outlined,
                title: 'Pregúntale al asistente',
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < detail.preguntas.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            title: Text(detail.preguntas[i]),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _ask(context, detail.preguntas[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Encabezado del trámite: icono, nombre, categoría y sello de verificación.
class _Hero extends StatelessWidget {
  const _Hero({required this.detail});

  final TramiteDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(tramiteIcon(detail.id), color: scheme.primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(detail.nombre, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(label: Text(detail.categoria)),
            if (detail.fechaVerificacion.isNotEmpty)
              _VerifiedStamp(date: _formatDate(detail.fechaVerificacion)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          detail.descripcion,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
        ),
      ],
    );
  }
}

/// Sello que indica cuándo se verificó la información del trámite.
class _VerifiedStamp extends StatelessWidget {
  const _VerifiedStamp({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.tertiary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SealMark(
            size: 18,
            color: scheme.onTertiaryContainer,
            strokeWidth: 1.4,
          ),
          const SizedBox(width: 6),
          Text(
            'Verificado el $date',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 12),
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
    final accent = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichMessage(
                    text: item,
                    style: style,
                    linkColor: accent,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Pasos del trámite como línea de tiempo.
class _StepList extends StatelessWidget {
  const _StepList({required this.items, this.checked, this.onToggle});

  final List<String> items;

  /// Pasos marcados. Si es null, no hay seguimiento y se muestran números.
  final Set<int>? checked;
  final ValueChanged<int>? onToggle;

  @override
  Widget build(BuildContext context) {
    final tracking = checked != null && onToggle != null;

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _StepRow(
            number: i + 1,
            text: items[i],
            isLast: i == items.length - 1,
            done: tracking ? checked!.contains(i) : null,
            onToggle: tracking ? () => onToggle!(i) : null,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    required this.isLast,
    this.done,
    this.onToggle,
  });

  final int number;
  final String text;
  final bool isLast;

  /// null: sin seguimiento. true o false: casilla marcada o no.
  final bool? done;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tracking = done != null;
    final isDone = done ?? false;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (tracking)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isDone,
                      onChanged: (_) => onToggle?.call(),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 18),
              child: RichMessage(
                text: text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDone ? scheme.onSurfaceVariant : null,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
                linkColor: scheme.primary,
              ),
            ),
          ),
        ],
      ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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