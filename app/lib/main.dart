import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';
import 'services/mock_assistant_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      // Cuando exista el backend, aquí cambiaremos el servicio simulado.
      create: (_) => ChatProvider(MockAssistantService()),
      child: const UniTramiteApp(),
    ),
  );
}

class UniTramiteApp extends StatelessWidget {
  const UniTramiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniTrámite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}