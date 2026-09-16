/// Billing frequency of a [Subscription].
enum SubscriptionType {
  weekly,
  monthly,
  yearly;

  static SubscriptionType fromName(String name) {
    return SubscriptionType.values.firstWhere((value) => value.name == name);
  }
}
