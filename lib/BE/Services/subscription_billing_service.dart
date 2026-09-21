import 'dart:async';

import '../context/deposit_repository.dart';
import '../context/subscription_repository.dart';
import '../context/transaction_repository.dart';
import '../entities/subscription.dart';
import '../entities/subscription_type.dart';
import '../entities/transaction.dart';

/// The calendar date of [date] (year/month/day, no time-of-day), represented
/// in UTC so that adding whole-day [Duration]s always lands on the expected
/// day regardless of the local time zone's daylight-saving transitions.
DateTime _calendarDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

/// How many billing periods have fully elapsed [since] a subscription's last
/// charge (or its creation, if never charged), as of [now].
///
/// [lastBilledDate] is the date that should be recorded as the new
/// "last billed" date once [chargesDue] transactions have been registered —
/// it equals the calendar date of [since] unchanged when nothing is due.
({int chargesDue, DateTime lastBilledDate}) computeDueCharges({
  required DateTime since,
  required Duration period,
  required DateTime now,
}) {
  final nowDate = _calendarDate(now);

  var chargesDue = 0;
  var cursor = _calendarDate(since);
  var nextDue = cursor.add(period);
  while (!nextDue.isAfter(nowDate)) {
    chargesDue++;
    cursor = nextDue;
    nextDue = cursor.add(period);
  }
  return (chargesDue: chargesDue, lastBilledDate: cursor);
}

/// Charges active subscriptions whose billing period has elapsed, and keeps
/// doing so once a day while the app is running.
///
/// Each elapsed period registers exactly one expense [Transaction] against
/// the subscription's deposit; a subscription already charged for a period
/// is never charged again for it, and inactive subscriptions are skipped.
class SubscriptionBillingService {
  final SubscriptionRepository _subscriptionRepository;
  final DepositRepository _depositRepository;
  final TransactionRepository _transactionRepository;

  Timer? _dailyTimer;

  SubscriptionBillingService({
    SubscriptionRepository? subscriptionRepository,
    DepositRepository? depositRepository,
    TransactionRepository? transactionRepository,
  }) : _subscriptionRepository =
           subscriptionRepository ?? SubscriptionRepository(),
       _depositRepository = depositRepository ?? DepositRepository(),
       _transactionRepository =
           transactionRepository ?? TransactionRepository();

  /// Charges every active subscription that is due, based on the current
  /// time. Meant to be called once when the app starts.
  Future<void> chargeDueSubscriptions() async {
    final subscriptions = await _subscriptionRepository.getAll();
    final now = DateTime.now();

    for (final subscription in subscriptions.where((s) => s.isActive)) {
      await _chargeIfDue(subscription, now);
    }
  }

  /// Schedules [chargeDueSubscriptions] to run once at the next local
  /// midnight, then every 24 hours after that, for as long as the app keeps
  /// running.
  void scheduleDailyCheck() {
    _dailyTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _dailyTimer = Timer(nextMidnight.difference(now), () {
      chargeDueSubscriptions();
      _dailyTimer = Timer.periodic(
        const Duration(days: 1),
        (_) => chargeDueSubscriptions(),
      );
    });
  }

  void dispose() {
    _dailyTimer?.cancel();
  }

  Future<void> _chargeIfDue(Subscription subscription, DateTime now) async {
    final since = subscription.lastBilledDate ?? subscription.creationDate;
    final result = computeDueCharges(
      since: since,
      period: subscription.type.billingPeriod,
      now: now,
    );
    if (result.chargesDue == 0) return;

    var dueDate = _calendarDate(since).add(subscription.type.billingPeriod);
    for (var i = 0; i < result.chargesDue; i++) {
      await _transactionRepository.create(
        Transaction(
          transactionTypeId: subscription.transactionTypeId,
          depositId: subscription.depositId,
          transactionDate: dueDate,
          amount: subscription.cost,
          isPositive: false,
        ),
      );
      dueDate = dueDate.add(subscription.type.billingPeriod);
    }

    await _subscriptionRepository.update(
      subscription.copyWith(lastBilledDate: result.lastBilledDate),
    );

    final deposit = await _depositRepository.getById(subscription.depositId);
    if (deposit != null) {
      await _depositRepository.update(
        deposit.copyWith(
          account: deposit.account - subscription.cost * result.chargesDue,
        ),
      );
    }
  }
}
