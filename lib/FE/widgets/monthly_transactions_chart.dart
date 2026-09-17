import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../BE/entities/deposit.dart';
import '../../BE/entities/transaction.dart';
import 'deposit_color.dart';
import 'monthly_totals.dart';

/// Line chart of the current month's daily transaction totals.
///
/// With no [selectedDepositIds], every transaction is summed into a single
/// undifferentiated line. Each selected deposit instead gets its own line,
/// colored with that deposit's [Deposit.color].
class MonthlyTransactionsChart extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Deposit> deposits;
  final Set<int> selectedDepositIds;

  const MonthlyTransactionsChart({
    super.key,
    required this.transactions,
    required this.deposits,
    required this.selectedDepositIds,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final defaultColor = Theme.of(context).colorScheme.primary;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineBarsData: _buildLines(now.year, now.month, defaultColor),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString()),
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 48),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLines(int year, int month, Color defaultColor) {
    if (selectedDepositIds.isEmpty) {
      final totals = computeDailyTotals(
        transactions: transactions,
        year: year,
        month: month,
      );
      return [_lineFor(totals, defaultColor)];
    }

    return [
      for (final deposit in deposits)
        if (selectedDepositIds.contains(deposit.id))
          _lineFor(
            computeDailyTotals(
              transactions: transactions,
              year: year,
              month: month,
              depositId: deposit.id,
            ),
            parseDepositColor(deposit.color),
          ),
    ];
  }

  LineChartBarData _lineFor(List<DailyTotal> totals, Color color) {
    return LineChartBarData(
      spots: [
        for (final total in totals) FlSpot(total.day.toDouble(), total.total),
      ],
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }
}
