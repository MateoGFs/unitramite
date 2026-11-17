import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/suggestions.dart';
import '../providers/chat_provider.dart';
import '../widgets/loading_bubble.dart';
import '../widgets/message_bubble.dart';
import '../widgets/seal_mark.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, this.initialQuestion});

  /// Pregunta escrita en la pantalla de inicio (abre una conversación nueva).
  final String? initialQuestion;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final question = widget.initialQuestion;
    if (question != null && question.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final chat = context.read<ChatProvider>();
        chat.startConversation();
        chat.sendQuestion(question);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _ask(String question) {
    final chat = context.read<ChatProvider>();
    if (chat.isLoading) return;
    chat.sendQuestion(question);
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _ask(text);
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        final messages = chat.messages;
        final itemCount = messages.length + (chat.isLoading ? 1 : 0);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Asistente'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: 'Nueva conversación',
                onPressed: chat.isLoading || !chat.hasMessages
                    ? null
                    : chat.startConversation,
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    Expanded(
                      child: itemCount == 0
                          ? _EmptyState(onAsk: _ask)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              itemCount: itemCount,
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return const LoadingBubble();
                                }
                                return MessageBubble(message: messages[index]);
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _submit(),
                              decoration: const InputDecoration(
                                hintText: 'Escribe tu pregunta…',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            icon: const Icon(Icons.send_rounded),
                            tooltip: 'Enviar',
                            style: IconButton.styleFrom(
                              minimumSize: const Size(52, 52),
                            ),
                            onPressed: chat.isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAsk});

  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Center(child: SealMark(size: 72, color: scheme.primary)),
        const SizedBox(height: 16),
        Text(
          'Pregúntame por un trámite',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Respondo con los trámites verificados de la Universidad de Nariño '
          'y te muestro de dónde sale cada dato.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final question in kSuggestedQuestions)
              ActionChip(
                label: Text(question),
                onPressed: () => onAsk(question),
              ),
          ],
        ),
      ],
    );
  }
}