import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tramites_provider.dart';
import '../widgets/tramite_card.dart';
import 'assistant_screen.dart';
import 'tramite_detail_screen.dart';

import '../providers/progress_provider.dart';
import 'my_tramites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAssistant([String? question]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssistantScreen(initialQuestion: question),
      ),
    );
  }

  void _submit([String? _]) {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    _controller.clear();
    _openAssistant(question);
  }

  Widget _buildTramites(BuildContext context, TramitesProvider tramites) {
    switch (tramites.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      case LoadStatus.error:
        return Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  tramites.error ?? 'No se pudieron cargar los trámites.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: tramites.load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      case LoadStatus.loaded:
        if (tramites.items.isEmpty) {
          return const Text('Aún no hay trámites disponibles.');
        }
        return Column(
          children: [
            for (final tramite in tramites.items)
              TramiteCard(
                tramite: tramite,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TramiteDetailScreen(tramiteId: tramite.id),
                  ),
                ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniTrámite'),
        actions: [
          IconButton(
            icon: Badge.count(
              count: activeCount,
              isLabelVisible: activeCount > 0,
              child: const Icon(Icons.checklist),
            ),
            tooltip: 'Mis trámites',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyTramitesScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Abrir conversación',
            onPressed: _openAssistant,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Qué trámite necesitas hacer?',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pregunta con tus palabras y te responderé con base en '
                  'documentos oficiales de la Universidad de Nariño.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _submit,
                  decoration: InputDecoration(
                    hintText: 'Ej: ¿Qué necesito para un certificado?',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submit,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Trámites disponibles', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildTramites(context, tramites),
              ],
            ),
          ),
        ),
      ),
    );
  }
}