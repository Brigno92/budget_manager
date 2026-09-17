import 'package:flutter/widgets.dart';

/// A single destination reachable from the side menu, paired with its route.
class AppPage {
  final String route;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;

  const AppPage({
    required this.route,
    required this.label,
    required this.icon,
    required this.builder,
  });
}
