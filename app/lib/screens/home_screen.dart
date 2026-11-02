import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/sample_tramites.dart';
import '../widgets/home/assistant_card.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/how_it_works_section.dart';
import '../widgets/home/search_hero_card.dart';
import '../widgets/home/tramite_card.dart';
import '../widgets/home/transparency_card.dart';
import 'assistant_screen.dart';

/// Pantalla de inicio. Solo compone widgets; la lógica del chat sigue en
/// ChatProvider y AssistantScreen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAllTramites, this.onSearch});

  final VoidCallback? onSeeAllTramites;
  final ValueChanged<String>? onSearch;

  static const List<QuickQuestion> _quickQuestions = [
    QuickQuestion(
      '¿Cómo tramitar certificado de notas?',
      Icons.chat_bubble_outline,
    ),
    QuickQuestion(
      '¿Cuándo vence el plazo de cancelación de materias?',
      Icons.schedule,
    ),
    QuickQuestion(
      '¿Cómo pago estampilla Pro-Udenar por PSE?',
      Icons.payments_outlined,
    ),
  ];

  void _openAssistant(BuildContext context, {String? question}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssistantScreen(initialQuestion: question),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onMenuPressed: () =>
            _showMessage(context, 'Menú: se activará más adelante'),
        onProfilePressed: () =>
            _showMessage(context, 'Perfil: se activará más adelante'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                SearchHeroCard(
                  onSearch: (query) {
                    final search = onSearch;
                    if (search != null) {
                      search(query);
                    } else {
                      _openAssistant(context, question: query);
                    }
                  },
                ),
                const SizedBox(height: 20),
                AssistantCard(
                  questions: _quickQuestions,
                  onQuestionTap: (question) =>
                      _openAssistant(context, question: question),
                  onStartChat: () => _openAssistant(context),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trámites recomendados',
                      style: AppTextStyles.sectionTitle,
                    ),
                    TextButton(
                      onPressed:
                          onSeeAllTramites ??
                          () => _showMessage(
                            context,
                            'El catálogo completo se activará más adelante',
                          ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final tramite in sampleTramites)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TramiteCard(
                      tramite: tramite,
                      onTap: () => _openAssistant(
                        context,
                        question: '¿Cómo hago el trámite "${tramite.title}"?',
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                const HowItWorksSection(),
                const SizedBox(height: 20),
                const TransparencyCard(
                  validityLabel: sampleDataValidity,
                  versionLabel: sampleVersionLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
