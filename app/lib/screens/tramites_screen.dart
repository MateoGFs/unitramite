import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/sample_tramites.dart';
import '../models/tramite.dart';
import '../widgets/tramites/results_header.dart';
import '../widgets/tramites/sort_menu.dart';
import '../widgets/tramites/tramite_result_card.dart';
import 'assistant_screen.dart';

/// Pedido de búsqueda que llega desde otra pantalla (por ejemplo el Home).
/// Cada búsqueda crea una instancia nueva, así repetir el mismo texto
/// también cuenta como un pedido nuevo.
class TramiteSearchRequest {
  const TramiteSearchRequest(this.query);

  final String query;
}

/// Pestaña "Trámites": búsqueda, orden y lista de resultados.
/// Filtra y ordena en el dispositivo sobre [sampleSearchResults]; cuando
/// haya backend, solo cambia de dónde sale la lista.
class TramitesScreen extends StatefulWidget {
  const TramitesScreen({super.key, this.onBack, this.searchRequest});

  /// Acción del botón "Volver" (el contenedor decide a dónde regresa).
  final VoidCallback? onBack;
  final TramiteSearchRequest? searchRequest;

  @override
  State<TramitesScreen> createState() => _TramitesScreenState();
}

class _TramitesScreenState extends State<TramitesScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  TramiteSort _sort = TramiteSort.relevance;

  @override
  void didUpdateWidget(TramitesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final request = widget.searchRequest;
    if (request != null && !identical(request, oldWidget.searchRequest)) {
      _controller.text = request.query;
      _query = request.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _normalize(String text) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    var result = text.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }

  /// Ordena por una clave numérica; los que no tienen dato van al final y
  /// los empates conservan el orden original.
  static List<Tramite> _sortedBy(
    List<Tramite> items,
    int? Function(Tramite) key,
  ) {
    final indexed = items.asMap().entries.toList();
    indexed.sort((a, b) {
      final ka = key(a.value);
      final kb = key(b.value);
      if (ka == kb) return a.key.compareTo(b.key);
      if (ka == null) return 1;
      if (kb == null) return -1;
      return ka.compareTo(kb);
    });
    return [for (final entry in indexed) entry.value];
  }

  List<Tramite> _visibleResults() {
    final words = _normalize(_query)
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    final filtered = sampleSearchResults.where((tramite) {
      final haystack = _normalize(
        '${tramite.title} ${tramite.entity} ${tramite.badge}',
      );
      return words.every(haystack.contains);
    }).toList();

    return switch (_sort) {
      TramiteSort.relevance => filtered,
      TramiteSort.cost => _sortedBy(filtered, (t) => t.costCop),
      TramiteSort.time => _sortedBy(filtered, (t) => t.minDurationHours),
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _askAssistant(String question) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssistantScreen(initialQuestion: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _visibleResults();
    final query = _query.trim();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final margin = width >= 600 ? 32.0 : 20.0;
            final columns = width >= 900 ? 2 : 1;

            return Column(
              children: [
                ResultsHeader(
                  controller: _controller,
                  onChanged: (value) => setState(() => _query = value),
                  onBack: widget.onBack,
                  onHelp: () => _showMessage('Ayuda: se activará más adelante'),
                  horizontalPadding: margin,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(margin, 14, margin, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ResultsBar(
                          count: results.length,
                          hasQuery: query.isNotEmpty,
                          sort: _sort,
                          onSortChanged: (sort) => setState(() => _sort = sort),
                        ),
                        const SizedBox(height: 14),
                        if (results.isEmpty)
                          _EmptyState(
                            query: query,
                            onAskAssistant: () => _askAssistant(
                              query.isEmpty
                                  ? '¿Qué trámites puedo hacer?'
                                  : query,
                            ),
                          )
                        else
                          _ResultsGrid(
                            items: results,
                            columns: columns,
                            onDetail: (tramite) => _showMessage(
                              'El detalle de "${tramite.title}" se activará más adelante',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResultsBar extends StatelessWidget {
  const _ResultsBar({
    required this.count,
    required this.hasQuery,
    required this.sort,
    required this.onSortChanged,
  });

  final int count;
  final bool hasQuery;
  final TramiteSort sort;
  final ValueChanged<TramiteSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final noun = count == 1 ? 'trámite' : 'trámites';
    final state = hasQuery
        ? (count == 1 ? 'encontrado' : 'encontrados')
        : (count == 1 ? 'disponible' : 'disponibles');

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.brandBorder.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brandMuted,
                ),
                children: [
                  TextSpan(
                    text: '$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDark,
                    ),
                  ),
                  TextSpan(text: ' $noun $state para estudiantes'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SortMenu(value: sort, onChanged: onSortChanged),
        ],
      ),
    );
  }
}

/// Reparte las tarjetas en [columns] columnas; con 1 columna es una lista.
class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({
    required this.items,
    required this.columns,
    required this.onDetail,
  });

  final List<Tramite> items;
  final int columns;
  final ValueChanged<Tramite> onDetail;

  @override
  Widget build(BuildContext context) {
    Widget card(int index) => TramiteResultCard(
      // La clave hace que cada tarjeta conserve su estado al reordenar.
      key: ValueKey(items[index].title),
      tramite: items[index],
      emphasized: index == 0,
      initiallyExpanded: index == 0,
      onDetail: () => onDetail(items[index]),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c > 0) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = c; i < items.length; i += columns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: card(i),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, required this.onAskAssistant});

  final String query;
  final VoidCallback onAskAssistant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.brandMuted),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? 'Aún no hay trámites para mostrar'
                : 'No encontramos trámites para "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.brandDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prueba con otras palabras o pregúntale al asistente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.brandMuted),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAskAssistant,
            icon: const Icon(Icons.forum_outlined, size: 18),
            label: const Text('Preguntar al asistente'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
