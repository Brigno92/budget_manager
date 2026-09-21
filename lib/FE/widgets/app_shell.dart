import 'package:flutter/material.dart';

import '../routing/app_routes.dart';
import 'register_transaction_dialog.dart';

/// Background of the fused side panel (header + nav rail): a shade darker
/// than the app's own background, so the panel reads as one continuous
/// shape distinct from the content area behind it.
const _panelColor = Color(0xFF14161A);

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

  Future<void> _handleAdd() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => const RegisterTransactionDialog(),
    );
    // A new transaction can change the current page's data (e.g. Home's
    // balance and chart, or the Registro table): rebuild it to refetch.
    if (saved == true) {
      _contentNavigatorKey.currentState?.pushReplacementNamed(_currentRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = AppRoutes.pageForRoute(_currentRoute);
    final selectedIndex = AppRoutes.pages.indexOf(currentPage);

    return Scaffold(
      body: Row(
        children: [
          // The header and the nav rail share the same background and sit
          // in the same Container, so they read as a single fused panel
          // instead of a separate top bar sitting above the side menu.
          Container(
            color: _panelColor,
            child: Column(
              children: [
                const SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet),
                      SizedBox(width: 8),
                      Text(
                        'Budget Manager',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
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
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    currentPage.label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: Navigator(
                    key: _contentNavigatorKey,
                    initialRoute: AppRoutes.initialRoute,
                    onGenerateRoute: AppRoutes.onGenerateRoute,
                  ),
                ),
              ],
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
