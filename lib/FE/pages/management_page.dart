import 'package:flutter/material.dart';

import '../../BE/context/transaction_type_repository.dart';
import '../../BE/entities/transaction_type.dart';
import '../widgets/transaction_type_form_dialog.dart';

/// Lists the registered transaction types ("Tipologie") in a table, with an
/// "Aggiungi" button that opens [TransactionTypeFormDialog] to create a new
/// one, and a "Dettaglio" action per row that opens the same dialog to edit
/// that type.
class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  final TransactionTypeRepository _transactionTypeRepository =
      TransactionTypeRepository();
  late Future<List<TransactionType>> _typesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _typesFuture = _transactionTypeRepository.getAll());
  }

  Future<void> _openForm({TransactionType? existing}) async {
    final result = await showDialog<TransactionType>(
      context: context,
      builder: (_) => TransactionTypeFormDialog(existing: existing),
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
            child: FutureBuilder<List<TransactionType>>(
              future: _typesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Errore nel caricamento: ${snapshot.error}'),
                  );
                }

                final types = snapshot.data!;
                if (types.isEmpty) {
                  return const Center(
                    child: Text('Nessuna tipologia registrata'),
                  );
                }

                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('Azioni')),
                      ],
                      rows: [
                        for (final type in types)
                          DataRow(
                            cells: [
                              DataCell(Text(type.name)),
                              DataCell(
                                TextButton(
                                  onPressed: () => _openForm(existing: type),
                                  child: const Text('Dettaglio'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
