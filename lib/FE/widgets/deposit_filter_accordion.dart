import 'package:flutter/material.dart';

import '../../BE/entities/deposit.dart';
import 'deposit_color.dart';

/// Collapsible, collapsed-by-default list of per-deposit checkboxes used to
/// filter which deposits' transactions are plotted on the home chart.
///
/// Every checkbox starts unchecked, matching the "no filter" state where the
/// chart shows all deposits combined.
class DepositFilterAccordion extends StatelessWidget {
  final List<Deposit> deposits;
  final Set<int> selectedDepositIds;
  final ValueChanged<int> onToggle;

  const DepositFilterAccordion({
    super.key,
    required this.deposits,
    required this.selectedDepositIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filtri'),
      children: [
        for (final deposit in deposits)
          if (deposit.id != null)
            CheckboxListTile(
              value: selectedDepositIds.contains(deposit.id),
              onChanged: (_) => onToggle(deposit.id!),
              activeColor: parseDepositColor(deposit.color),
              secondary: CircleAvatar(
                radius: 8,
                backgroundColor: parseDepositColor(deposit.color),
              ),
              title: Text(deposit.name),
            ),
      ],
    );
  }
}
