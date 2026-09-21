import 'package:budget_manager/BE/Services/subscription_billing_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeDueCharges', () {
    test('is not due before a full period has elapsed', () {
      final result = computeDueCharges(
        since: DateTime.utc(2026, 1, 1),
        period: const Duration(days: 30),
        now: DateTime.utc(2026, 1, 15),
      );

      expect(result.chargesDue, 0);
      expect(result.lastBilledDate, DateTime.utc(2026, 1, 1));
    });

    test('is due exactly once right after a period elapses', () {
      final result = computeDueCharges(
        since: DateTime.utc(2026, 1, 1),
        period: const Duration(days: 30),
        now: DateTime.utc(2026, 1, 31),
      );

      expect(result.chargesDue, 1);
      expect(result.lastBilledDate, DateTime.utc(2026, 1, 31));
    });

    test('catches up multiple missed periods in one call', () {
      final result = computeDueCharges(
        since: DateTime.utc(2026, 1, 1),
        period: const Duration(days: 30),
        now: DateTime.utc(2026, 4, 1),
      );

      expect(result.chargesDue, 3);
      expect(
        result.lastBilledDate,
        DateTime.utc(2026, 1, 1).add(const Duration(days: 90)),
      );
    });

    test('is never due twice for the same period once caught up', () {
      final firstRun = computeDueCharges(
        since: DateTime.utc(2026, 1, 1),
        period: const Duration(days: 30),
        now: DateTime.utc(2026, 2, 1),
      );
      final secondRun = computeDueCharges(
        since: firstRun.lastBilledDate,
        period: const Duration(days: 30),
        now: DateTime.utc(2026, 2, 1),
      );

      expect(firstRun.chargesDue, 1);
      expect(secondRun.chargesDue, 0);
    });

    test('normalizes away any time-of-day component before comparing', () {
      final result = computeDueCharges(
        since: DateTime(2026, 1, 1, 23, 30),
        period: const Duration(days: 30),
        now: DateTime(2026, 1, 31, 0, 30),
      );

      expect(result.chargesDue, 1);
    });
  });
}
