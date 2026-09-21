/// Billing frequency of a [Subscription].
enum SubscriptionType {
  weekly,
  monthly,
  yearly;

  static SubscriptionType fromName(String name) {
    return SubscriptionType.values.firstWhere((value) => value.name == name);
  }
}

extension SubscriptionTypeLabels on SubscriptionType {
  /// The Italian label shown in the UI.
  String get label {
    switch (this) {
      case SubscriptionType.weekly:
        return 'Settimanale';
      case SubscriptionType.monthly:
        return 'Mensile';
      case SubscriptionType.yearly:
        return 'Annuale';
    }
  }

  /// How often this subscription is billed, used to decide when a payment
  /// is due. Fixed-length periods (not calendar weeks/months/years), e.g. a
  /// monthly subscription is due every 30 days.
  Duration get billingPeriod {
    switch (this) {
      case SubscriptionType.weekly:
        return const Duration(days: 7);
      case SubscriptionType.monthly:
        return const Duration(days: 30);
      case SubscriptionType.yearly:
        return const Duration(days: 365);
    }
  }
}
