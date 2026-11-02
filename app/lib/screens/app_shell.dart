import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'placeholder_screen.dart';
import 'tramites_screen.dart';

/// Contenedor principal con la navegación inferior de 4 pestañas.
/// IndexedStack conserva el estado de cada pestaña al cambiar entre ellas.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int _homeTab = 0;
  static const int _tramitesTab = 1;

  int _index = _homeTab;
  TramiteSearchRequest? _searchRequest;

  void _select(int index) => setState(() => _index = index);

  /// Lleva la búsqueda escrita en el Home a la pestaña Trámites.
  void _search(String query) {
    setState(() {
      _searchRequest = TramiteSearchRequest(query);
      _index = _tramitesTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onSeeAllTramites: () => _select(_tramitesTab),
        onSearch: _search,
      ),
      TramitesScreen(
        onBack: () => _select(_homeTab),
        searchRequest: _searchRequest,
      ),
      const PlaceholderScreen(title: 'Alertas', icon: Icons.notifications_none),
      const PlaceholderScreen(title: 'Perfil', icon: Icons.person_outline),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.brandBorder)),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Trámites',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alertas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
