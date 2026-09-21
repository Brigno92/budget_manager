import 'package:flutter/material.dart';

import '../../BE/context/deposit_repository.dart';
import '../../BE/context/transaction_repository.dart';
import '../../BE/entities/deposit.dart';
import '../../BE/entities/transaction.dart';
import '../widgets/currency_format.dart';
import '../widgets/deposit_filter_accordion.dart';
import '../widgets/monthly_transactions_chart.dart';

typedef _HomeData = ({List<Deposit> deposits, List<Transaction> transactions});

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DepositRepository _depositRepository = DepositRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final Set<int> _selectedDepositIds = {};

  late Future<_HomeData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_HomeData> _loadData() async {
    final deposits = await _depositRepository.getAll();
    final transactions = await _transactionRepository.getAll();
    return (deposits: deposits, transactions: transactions);
  }

  void _toggleDeposit(int depositId) {
    setState(() {
      if (!_selectedDepositIds.remove(depositId)) {
        _selectedDepositIds.add(depositId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
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
        final balance = data.deposits.fold<int>(
          0,
          (sum, deposit) => sum + deposit.account,
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Text(
                'Hello!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bilancio: ${formatEuroAmount(balance)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // The chart keeps a plain light theme inside its white card,
            // regardless of the app's dark theme around it. `Theme` alone
            // doesn't repaint inherited text/icon color, so both are
            // overridden explicitly for anything the chart draws as a
            // plain Text/Icon (e.g. fl_chart's axis labels).
            Card(
              color: Colors.white,
              child: Theme(
                data: ThemeData.light(),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.black87),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: Colors.black87),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: MonthlyTransactionsChart(
                        transactions: data.transactions,
                        deposits: data.deposits,
                        selectedDepositIds: _selectedDepositIds,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DepositFilterAccordion(
              deposits: data.deposits,
              selectedDepositIds: _selectedDepositIds,
              onToggle: _toggleDeposit,
            ),
          ],
        );
      },
    );
  }
}
