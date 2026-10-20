import 'package:flutter/material.dart';

import 'assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  // Provisionales: más adelante saldrán de los documentos cargados.
  static const List<String> _categories = [
    'Trámites académicos',
    'Certificados',
    'Solicitudes administrativas',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit([String? _]) {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    _controller.clear();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssistantScreen(initialQuestion: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('UniTrámite')),
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
                const SizedBox(height: 24),
                Text('Categorías', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in _categories)
                      ActionChip(
                        label: Text(category),
                        onPressed: () =>
                            _showMessage('$category: se activará más adelante'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
