import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/suggestions.dart';
import '../core/theme/app_colors.dart';
import '../providers/progress_provider.dart';
import '../providers/tramites_provider.dart';
import '../widgets/seal_mark.dart';
import '../widgets/state_message.dart';
import '../widgets/tramite_card.dart';
import 'assistant_screen.dart';
import 'history_screen.dart';
import 'my_tramites_screen.dart';
import 'tramite_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _contentWidth = 640;

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openAssistant([String? question]) =>
      _push(AssistantScreen(initialQuestion: question));

  void _submit([String? _]) {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    _controller.clear();
    _openAssistant(question);
  }

  Widget _headerAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    int badge = 0,
  }) {
    return IconButton(
      color: Colors.white,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Badge.count(
        count: badge,
        isLabelVisible: badge > 0,
        backgroundColor: AppColors.stamp,
        textColor: AppColors.inkDark,
        child: Icon(icon),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topInset, int activeCount) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.inkDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -56,
            top: topInset + 36,
            child: SealMark(
              size: 220,
              color: AppColors.stamp.withValues(alpha: 0.28),
              strokeWidth: 2.5,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _contentWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topInset + 8, 12, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'UniTrámite',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _headerAction(
                          icon: Icons.history,
                          tooltip: 'Historial',
                          onPressed: () => _push(const HistoryScreen()),
                        ),
                        _headerAction(
                          icon: Icons.checklist,
                          tooltip: 'Mis trámites',
                          badge: activeCount,
                          onPressed: () => _push(const MyTramitesScreen()),
                        ),
                        _headerAction(
                          icon: Icons.chat_bubble_outline,
                          tooltip: 'Abrir conversación',
                          onPressed: _openAssistant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '¿Qué trámite necesitas hacer hoy?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Pregunta con tus palabras. Respondo solo con '
                      'información oficial de la Universidad de Nariño.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFC9D2EE),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _submit,
                        decoration: InputDecoration(
                          hintText: 'Ej: ¿Qué necesito para un certificado?',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: IconButton.filled(
                              icon: const Icon(Icons.arrow_upward_rounded),
                              tooltip: 'Preguntar',
                              onPressed: _submit,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTramites(BuildContext context, TramitesProvider tramites) {
    switch (tramites.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      case LoadStatus.error:
        return StateMessage(
          icon: Icons.cloud_off_outlined,
          title: 'No se pudieron cargar los trámites',
          message: tramites.error,
          actionLabel: 'Reintentar',
          onAction: tramites.load,
        );
      case LoadStatus.loaded:
        if (tramites.items.isEmpty) {
          return const StateMessage(
            icon: Icons.inbox_outlined,
            title: 'Aún no hay trámites disponibles',
          );
        }
        return Column(
          children: [
            for (final tramite in tramites.items)
              TramiteCard(
                tramite: tramite,
                onTap: () => _push(TramiteDetailScreen(tramiteId: tramite.id)),
              ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tramites = context.watch<TramitesProvider>();
    final activeCount = context.watch<ProgressProvider>().activeCount;
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context, topInset, activeCount),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: kSuggestedQuestions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final question = kSuggestedQuestions[index];
                          return ActionChip(
                            label: Text(question),
                            onPressed: () => _openAssistant(question),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Trámites',
                                  style: theme.textTheme.headlineSmall,
                                ),
                              ),
                              if (tramites.status == LoadStatus.loaded)
                                Text(
                                  '${tramites.items.length} con fuentes oficiales',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildTramites(context, tramites),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}