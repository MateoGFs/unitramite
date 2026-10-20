import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../widgets/loading_bubble.dart';
import '../widgets/message_bubble.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key, this.initialQuestion});

  /// Pregunta escrita en la pantalla de inicio (se envía al abrir).
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
        if (mounted) context.read<ChatProvider>().sendQuestion(question);
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

  void _submit() {
    final chat = context.read<ChatProvider>();
    final text = _controller.text.trim();
    if (text.isEmpty || chat.isLoading) return;
    _controller.clear();
    chat.sendQuestion(text);
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
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Nueva conversación',
                onPressed: chat.isLoading ? null : chat.clear,
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    Expanded(
                      child: itemCount == 0
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Escribe tu primera pregunta sobre un trámite.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
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
                            icon: const Icon(Icons.send),
                            tooltip: 'Enviar',
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