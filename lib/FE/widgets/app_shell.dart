import 'package:flutter/material.dart';

import '../routing/app_routes.dart';
import 'register_transaction_dialog.dart';

/// Persistent app frame: a left-hand side menu, a routed content area on
/// the right, and a bottom-right "add" floating action button.
///
/// Selecting a menu entry navigates the content area's own [Navigator] to
/// the matching route from [AppRoutes], without rebuilding the menu.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<NavigatorState> _contentNavigatorKey =
      GlobalKey<NavigatorState>();
  String _currentRoute = AppRoutes.initialRoute;

  void _selectRoute(String route) {
    if (route == _currentRoute) return;
    setState(() => _currentRoute = route);
    _contentNavigatorKey.currentState?.pushReplacementNamed(route);
  }

  void _handleAdd() {
    showDialog<bool>(
      context: context,
      builder: (_) => const RegisterTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = AppRoutes.pageForRoute(_currentRoute);
    final selectedIndex = AppRoutes.pages.indexOf(currentPage);

    return Scaffold(
      appBar: AppBar(title: Text(currentPage.label)),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (index) =>
                _selectRoute(AppRoutes.pages[index].route),
            destinations: [
              for (final page in AppRoutes.pages)
                NavigationRailDestination(
                  icon: Icon(page.icon),
                  label: Text(page.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Navigator(
              key: _contentNavigatorKey,
              initialRoute: AppRoutes.initialRoute,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAdd,
        tooltip: 'Aggiungi',
        child: const Icon(Icons.add),
      ),
    );
  }
}
