import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum TramiteSort { relevance, cost, time }

extension TramiteSortLabel on TramiteSort {
  String get label => switch (this) {
        TramiteSort.relevance => 'Relevancia',
        TramiteSort.cost => 'Menor costo',
        TramiteSort.time => 'Menor tiempo',
      };
}

/// Selector de orden con forma de píldora que abre un menú.
class SortMenu extends StatelessWidget {
  const SortMenu({super.key, required this.value, required this.onChanged});

  final TramiteSort value;
  final ValueChanged<TramiteSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TramiteSort>(
      tooltip: 'Ordenar resultados',
      initialValue: value,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => [
        for (final sort in TramiteSort.values)
          PopupMenuItem<TramiteSort>(value: sort, child: Text(sort.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.brandBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              value.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
