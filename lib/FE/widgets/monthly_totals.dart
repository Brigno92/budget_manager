import '../../BE/entities/transaction.dart';

/// The net total (income minus expenses) of transactions recorded on a
/// single day of the month, where `day` is the 1-based day-of-month.
class DailyTotal {
  final int day;
  final double total;

  const DailyTotal({required this.day, required this.total});
}

/// Sums [transactions] per day of [year]/[month].
///
/// When [depositId] is given, only transactions on that deposit are summed;
/// otherwise every transaction in the month counts. Returns one [DailyTotal]
/// per day of the month, in order, even for days with no transactions.
List<DailyTotal> computeDailyTotals({
  required List<Transaction> transactions,
  required int year,
  required int month,
  int? depositId,
}) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final totals = List<double>.filled(daysInMonth, 0);

  for (final transaction in transactions) {
    final date = transaction.transactionDate;
    if (date.year != year || date.month != month) continue;
    if (depositId != null && transaction.depositId != depositId) continue;

    final signedAmount = transaction.isPositive
        ? transaction.amount.toDouble()
        : -transaction.amount.toDouble();
    totals[date.day - 1] += signedAmount;
  }

  return [
    for (var day = 1; day <= daysInMonth; day++)
      DailyTotal(day: day, total: totals[day - 1]),
  ];
}
