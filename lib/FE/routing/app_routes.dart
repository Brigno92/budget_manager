import 'package:flutter/material.dart';

import '../pages/deposits_page.dart';
import '../pages/home_page.dart';
import '../pages/management_page.dart';
import '../pages/subscriptions_page.dart';
import '../pages/transactions_page.dart';
import 'app_page.dart';

/// Central registry of the app's navigable pages.
///
/// The side menu is built from [pages], so adding an [AppPage] here is
/// enough to make a new page reachable from the menu and from routing.
class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String deposits = '/deposits';
  static const String subscriptions = '/subscriptions';
  static const String management = '/management';

  static const String initialRoute = home;

  static final List<AppPage> pages = [
    AppPage(
      route: home,
      label: 'Home',
      icon: Icons.home,
      builder: (_) => const HomePage(),
    ),
    AppPage(
      route: transactions,
      label: 'Registro',
      icon: Icons.swap_horiz,
      builder: (_) => const TransactionsPage(),
    ),
    AppPage(
      route: deposits,
      label: 'Depositi',
      icon: Icons.account_balance_wallet,
      builder: (_) => const DepositsPage(),
    ),
    AppPage(
      route: subscriptions,
      label: 'Abbonamenti',
      icon: Icons.subscriptions,
      builder: (_) => const SubscriptionsPage(),
    ),
    AppPage(
      route: management,
      label: 'Gestione',
      icon: Icons.settings,
      builder: (_) => const ManagementPage(),
    ),
  ];

  static AppPage pageForRoute(String route) {
    return pages.firstWhere(
      (page) => page.route == route,
      orElse: () => pages.first,
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = pageForRoute(settings.name ?? initialRoute);
    return MaterialPageRoute(builder: page.builder, settings: settings);
  }
}
