import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/chat_provider.dart';
import 'providers/tramites_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_assistant_service.dart';
import 'services/api_tramites_service.dart';
import 'providers/progress_provider.dart';
import 'services/shared_prefs_progress_store.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ApiAssistantService()),
        ),
        ChangeNotifierProvider(
          create: (_) => TramitesProvider(ApiTramitesService())..load(),
        ),

        ChangeNotifierProvider(
          create: (_) => ProgressProvider(SharedPrefsProgressStore())..load(),
        ),
      ],
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