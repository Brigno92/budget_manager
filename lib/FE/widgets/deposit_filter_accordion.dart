import 'package:flutter/material.dart';

import '../../BE/entities/deposit.dart';
import 'deposit_color.dart';

/// Collapsible, collapsed-by-default list of per-deposit checkboxes used to
/// filter which deposits' transactions are plotted on the home chart.
///
/// Every checkbox starts unchecked, matching the "no filter" state where the
/// chart shows all deposits combined.
class DepositFilterAccordion extends StatefulWidget {
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
  State<DepositFilterAccordion> createState() => _DepositFilterAccordionState();
}

class _DepositFilterAccordionState extends State<DepositFilterAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Filtri',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: !_expanded
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final deposit in widget.deposits)
                      if (deposit.id != null)
                        CheckboxListTile(
                          value: widget.selectedDepositIds.contains(deposit.id),
                          onChanged: (_) => widget.onToggle(deposit.id!),
                          activeColor: parseDepositColor(deposit.color),
                          secondary: CircleAvatar(
                            radius: 8,
                            backgroundColor: parseDepositColor(deposit.color),
                          ),
                          title: Text(deposit.name),
                        ),
                  ],
                ),
        ),
      ],
    );
  }
}
