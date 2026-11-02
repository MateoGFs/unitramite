import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Encabezado fijo: volver, título, ayuda y campo de búsqueda con borrado.
class ResultsHeader extends StatelessWidget {
  const ResultsHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onBack,
    required this.onHelp,
    required this.horizontalPadding,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBack;
  final VoidCallback onHelp;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding - 8, 8, horizontalPadding - 8, 10),
      decoration: const BoxDecoration(
        color: AppColors.warmWhite,
        border: Border(bottom: BorderSide(color: AppColors.brandBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null)
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  label: const Text('Volver'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandDark,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),
              const Flexible(
                child: Text(
                  'Resultados de búsqueda',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: onHelp,
                tooltip: 'Ayuda e información de trámites',
                icon: const Icon(Icons.help_outline, size: 22),
                color: AppColors.brandMuted,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _SearchField(controller: controller, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: BoxDecoration(
        color: AppColors.tealSoft.withValues(alpha: 0.65),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 21, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.brandDark,
              ),
              decoration: const InputDecoration(
                hintText: 'Buscar trámites y servicios',
                hintStyle: TextStyle(color: AppColors.brandMuted),
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // El botón de borrar solo aparece cuando hay texto.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 8);
              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                tooltip: 'Limpiar búsqueda',
                icon: const Icon(Icons.close, size: 17),
                color: AppColors.brandMuted,
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ],
      ),
    );
  }
}
