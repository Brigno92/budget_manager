import 'package:budget_manager/BE/entities/transaction.dart';
import 'package:budget_manager/FE/widgets/monthly_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeDailyTotals', () {
    test('returns one entry per day of the month, zeroed by default', () {
      final totals = computeDailyTotals(transactions: [], year: 2026, month: 2);

      expect(totals, hasLength(28)); // February 2026 is not a leap year.
      expect(totals.every((t) => t.total == 0), isTrue);
      expect(totals.first.day, 1);
      expect(totals.last.day, 28);
    });

    test(
      'sums expenses as positive and income as negative on the same day',
      () {
        final totals = computeDailyTotals(
          transactions: [
            Transaction(
              transactionTypeId: 1,
              depositId: 1,
              transactionDate: DateTime(2026, 3, 5),
              amount: 100,
              isPositive: true,
            ),
            Transaction(
              transactionTypeId: 1,
              depositId: 1,
              transactionDate: DateTime(2026, 3, 5),
              amount: 40,
              isPositive: false,
            ),
          ],
          year: 2026,
          month: 3,
        );

        expect(totals[4].day, 5);
        expect(totals[4].total, -60);
      },
    );

    test('ignores transactions outside the requested month', () {
      final totals = computeDailyTotals(
        transactions: [
          Transaction(
            transactionTypeId: 1,
            depositId: 1,
            transactionDate: DateTime(2026, 4, 1),
            amount: 100,
            isPositive: true,
          ),
        ],
        year: 2026,
        month: 3,
      );

      expect(totals.every((t) => t.total == 0), isTrue);
    });

    test('filters by depositId when given', () {
      final totals = computeDailyTotals(
        transactions: [
          Transaction(
            transactionTypeId: 1,
            depositId: 1,
            transactionDate: DateTime(2026, 3, 10),
            amount: 50,
            isPositive: true,
          ),
          Transaction(
            transactionTypeId: 1,
            depositId: 2,
            transactionDate: DateTime(2026, 3, 10),
            amount: 999,
            isPositive: true,
          ),
        ],
        year: 2026,
        month: 3,
        depositId: 1,
      );

      expect(totals[9].total, -50);
    });
  });
}
