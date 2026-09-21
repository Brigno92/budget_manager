import 'dart:async';

import 'package:flutter/material.dart';

import 'BE/Services/subscription_billing_service.dart';
import 'BE/context/app_database.dart';
import 'FE/widgets/app_shell.dart';

void main() {
  AppDatabase.initializeFactory();

  final billingService = SubscriptionBillingService();
  unawaited(billingService.chargeDueSubscriptions());
  billingService.scheduleDailyCheck();

  runApp(const MyApp());
}

/// Dark-grey background with electric-blue text, icons and lines, used
/// app-wide. Widgets that need to stand out from this look (e.g. the home
/// chart's card) opt out locally with their own [Theme].
const appBackgroundColor = Color(0xFF1B1D22);
const appAccentColor = Colors.blueAccent;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Typography.material2021(platform: TargetPlatform.android)
        .white
        .apply(bodyColor: appAccentColor, displayColor: appAccentColor);

    return MaterialApp(
      title: 'Budget Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: appBackgroundColor,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: appAccentColor,
              brightness: Brightness.dark,
            ).copyWith(
              primary: appAccentColor,
              onPrimary: appBackgroundColor,
              secondary: appAccentColor,
              surface: appBackgroundColor,
              onSurface: appAccentColor,
            ),
        textTheme: textTheme,
        iconTheme: const IconThemeData(color: appAccentColor),
        dividerColor: appAccentColor.withValues(alpha: 0.4),
      ),
      home: const AppShell(),
    );
  }
}
