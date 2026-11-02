import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Tarjeta turquesa con el título y el buscador principal.
class SearchHeroCard extends StatefulWidget {
  const SearchHeroCard({super.key, required this.onSearch});

  /// Se llama con el texto escrito (ya sin espacios sobrantes).
  final ValueChanged<String> onSearch;

  @override
  State<SearchHeroCard> createState() => _SearchHeroCardState();
}

class _SearchHeroCardState extends State<SearchHeroCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final question = value.trim();
    if (question.isEmpty) return;
    _controller.clear();
    widget.onSearch(question);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué trámite necesitas consultar?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'OCARA, Bienestar, Consejos y normatividad Udenar',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.2,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              style: const TextStyle(fontSize: 14, color: AppColors.brandDark),
              decoration: const InputDecoration(
                hintText: '¿Qué trámite necesitas?',
                hintStyle: TextStyle(color: AppColors.brandMuted),
                prefixIcon: Icon(Icons.search, color: AppColors.primaryDark),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
