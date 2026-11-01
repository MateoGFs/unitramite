import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Pregunta sugerida que se muestra como botón.
class QuickQuestion {
  const QuickQuestion(this.text, this.icon);

  final String text;
  final IconData icon;
}

/// Tarjeta del asistente de IA con preguntas frecuentes y botón de chat.
class AssistantCard extends StatelessWidget {
  const AssistantCard({
    super.key,
    required this.questions,
    required this.onQuestionTap,
    required this.onStartChat,
  });

  final List<QuickQuestion> questions;
  final ValueChanged<String> onQuestionTap;
  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandPurple.withValues(alpha: 0.1),
            Colors.white,
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: AppColors.brandBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantHeader(),
          const SizedBox(height: 16),
          Text(
            'Preguntas frecuentes listas para consultar:'.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.brandMuted,
            ),
          ),
          const SizedBox(height: 6),
          for (final question in questions)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _QuestionTile(
                question: question,
                onTap: () => onQuestionTap(question.text),
              ),
            ),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: onStartChat,
            icon: const Icon(Icons.forum_outlined, size: 18),
            label: const Text('Iniciar conversación personalizada'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.brandPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.smart_toy_outlined, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Hablar con el asistente IA',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '24/7',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Resuelve dudas sobre requisitos, plazos y radicaciones',
                style: TextStyle(fontSize: 12, color: AppColors.brandMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({required this.question, required this.onTap});

  final QuickQuestion question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.brandBorder),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(question.icon, size: 15, color: AppColors.brandPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.brandMuted),
            ],
          ),
        ),
      ),
    );
  }
}
