import 'package:flutter/material.dart';

import '../../BE/context/deposit_repository.dart';
import '../../BE/entities/deposit.dart';
import '../widgets/color_preview_box.dart';
import '../widgets/currency_format.dart';
import '../widgets/deposit_color.dart';
import '../widgets/deposit_form_dialog.dart';

/// Lists the registered deposits in a table, with an "Aggiungi" button that
/// opens [DepositFormDialog] to create a new one, and a "Dettaglio" action
/// per row that opens the same dialog to edit that deposit.
class DepositsPage extends StatefulWidget {
  const DepositsPage({super.key});

  @override
  State<DepositsPage> createState() => _DepositsPageState();
}

class _DepositsPageState extends State<DepositsPage> {
  final DepositRepository _depositRepository = DepositRepository();
  late Future<List<Deposit>> _depositsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _depositsFuture = _depositRepository.getAll();
    });
  }

  Future<void> _openForm({Deposit? existing}) async {
    final result = await showDialog<Deposit>(
      context: context,
      builder: (_) => DepositFormDialog(existing: existing),
    );
    if (result != null) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Deposit>>(
              future: _depositsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Errore nel caricamento: ${snapshot.error}'),
                  );
                }

                final deposits = snapshot.data!;
                if (deposits.isEmpty) {
                  return const Center(
                    child: Text('Nessun deposito registrato'),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            dataTextStyle: const TextStyle(color: Colors.white),
                            columns: const [
                              DataColumn(label: Text('Nome')),
                              DataColumn(label: Text('Colore')),
                              DataColumn(label: Text('Conto')),
                              DataColumn(label: Text('Azioni')),
                            ],
                            rows: [
                              for (final deposit in deposits)
                                DataRow(
                                  cells: [
                                    DataCell(Text(deposit.name)),
                                    DataCell(
                                      ColorPreviewBox(
                                        color: parseDepositColor(deposit.color),
                                      ),
                                    ),
                                    DataCell(
                                      Text(formatEuroAmount(deposit.account)),
                                    ),
                                    DataCell(
                                      IconButton.outlined(
                                        icon: const Icon(Icons.info_outline),
                                        tooltip: 'Dettaglio',
                                        onPressed: () =>
                                            _openForm(existing: deposit),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
