import 'package:flutter/material.dart';

import '../../BE/context/deposit_repository.dart';
import '../../BE/context/transaction_repository.dart';
import '../../BE/context/transaction_type_repository.dart';
import '../../BE/entities/deposit.dart';
import '../../BE/entities/transaction.dart';
import '../../BE/entities/transaction_type.dart';
import '../widgets/currency_format.dart';
import '../widgets/date_format.dart';

enum _MovementFilter { all, income, expense }

typedef _RegisterData = ({
  List<Transaction> transactions,
  List<Deposit> deposits,
  List<TransactionType> types,
});

/// Lists every registered transaction ("Registro") in a table, filterable by
/// deposit, type, income/expense and date range.
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final DepositRepository _depositRepository = DepositRepository();
  final TransactionTypeRepository _transactionTypeRepository =
      TransactionTypeRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  late Future<_RegisterData> _dataFuture;

  int? _depositFilter;
  int? _typeFilter;
  _MovementFilter _movementFilter = _MovementFilter.all;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  Future<_RegisterData> _loadData() async {
    final transactions = await _transactionRepository.getAll();
    final deposits = await _depositRepository.getAll();
    final types = await _transactionTypeRepository.getAll();
    return (transactions: transactions, deposits: deposits, types: types);
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dateFrom = picked);
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dateTo = picked);
  }

  Future<void> _cancelTransaction(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annullare la transazione?'),
        content: const Text(
          'L\'importo verrà ripristinato sul deposito e la transazione '
          'verrà rimossa dal registro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Undo the balance change the transaction originally applied, then
    // remove it: transactions and the deposit's account are stored
    // separately, so both need updating.
    final deposit = await _depositRepository.getById(transaction.depositId);
    if (deposit != null) {
      final appliedDelta = transaction.isPositive
          ? transaction.amount
          : -transaction.amount;
      await _depositRepository.update(
        deposit.copyWith(account: deposit.account - appliedDelta),
      );
    }
    await _transactionRepository.delete(transaction.id!);

    _reload();
  }

  void _resetFilters() {
    setState(() {
      _depositFilter = null;
      _typeFilter = null;
      _movementFilter = _MovementFilter.all;
      _dateFrom = null;
      _dateTo = null;
    });
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    return transactions.where((transaction) {
      if (_depositFilter != null && transaction.depositId != _depositFilter) {
        return false;
      }
      if (_typeFilter != null && transaction.transactionTypeId != _typeFilter) {
        return false;
      }
      if (_movementFilter == _MovementFilter.income &&
          !transaction.isPositive) {
        return false;
      }
      if (_movementFilter == _MovementFilter.expense &&
          transaction.isPositive) {
        return false;
      }
      final date = DateUtils.dateOnly(transaction.transactionDate);
      if (_dateFrom != null && date.isBefore(DateUtils.dateOnly(_dateFrom!))) {
        return false;
      }
      if (_dateTo != null && date.isAfter(DateUtils.dateOnly(_dateTo!))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<_RegisterData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Errore nel caricamento: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          final filtered = _applyFilters(data.transactions);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilters(data.deposits, data.types),
              const SizedBox(height: 16),
              Expanded(child: _buildTable(filtered)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(List<Deposit> deposits, List<TransactionType> types) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<int?>(
          value: _depositFilter,
          hint: const Text('Deposito'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tutti i depositi'),
            ),
            for (final deposit in deposits)
              DropdownMenuItem<int?>(
                value: deposit.id,
                child: Text(deposit.name),
              ),
          ],
          onChanged: (value) => setState(() => _depositFilter = value),
        ),
        DropdownButton<int?>(
          value: _typeFilter,
          hint: const Text('Tipo'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Tutti i tipi'),
            ),
            for (final type in types)
              DropdownMenuItem<int?>(value: type.id, child: Text(type.name)),
          ],
          onChanged: (value) => setState(() => _typeFilter = value),
        ),
        DropdownButton<_MovementFilter>(
          value: _movementFilter,
          items: const [
            DropdownMenuItem(
              value: _MovementFilter.all,
              child: Text('Entrate e uscite'),
            ),
            DropdownMenuItem(
              value: _MovementFilter.income,
              child: Text('Solo entrate'),
            ),
            DropdownMenuItem(
              value: _MovementFilter.expense,
              child: Text('Solo uscite'),
            ),
          ],
          onChanged: (value) =>
              setState(() => _movementFilter = value ?? _MovementFilter.all),
        ),
        TextButton.icon(
          onPressed: _pickDateFrom,
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(_dateFrom == null ? 'Da' : formatItalianDate(_dateFrom!)),
        ),
        TextButton.icon(
          onPressed: _pickDateTo,
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(_dateTo == null ? 'A' : formatItalianDate(_dateTo!)),
        ),
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Azzera filtri'),
        ),
        IconButton(
          tooltip: 'Aggiorna',
          icon: const Icon(Icons.refresh),
          onPressed: _reload,
        ),
      ],
    );
  }

  Widget _buildTable(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Nessuna transazione trovata'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                dataTextStyle: const TextStyle(color: Colors.white),
                columns: const [
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Deposito')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Importo')),
                  DataColumn(label: Text('Azioni')),
                ],
                rows: [
                  for (final transaction in transactions)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(formatItalianDate(transaction.transactionDate)),
                        ),
                        DataCell(Text(transaction.deposit?.name ?? '—')),
                        DataCell(Text(transaction.type?.name ?? '—')),
                        DataCell(
                          Text(
                            '${transaction.isPositive ? '+' : '-'} ${formatEuroAmount(transaction.amount)}',
                            style: TextStyle(
                              color: transaction.isPositive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton.outlined(
                            icon: const Icon(Icons.undo),
                            tooltip: 'Annulla transazione',
                            onPressed: () => _cancelTransaction(transaction),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
