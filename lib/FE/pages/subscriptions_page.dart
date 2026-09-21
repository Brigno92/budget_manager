import 'package:flutter/material.dart';

import '../../BE/context/subscription_repository.dart';
import '../../BE/entities/subscription.dart';
import '../../BE/entities/subscription_type.dart';
import '../widgets/currency_format.dart';
import '../widgets/subscription_form_dialog.dart';

/// Lists the registered subscriptions in a table, with an "Aggiungi" button
/// that opens [SubscriptionFormDialog] to create a new one, and a
/// "Disattiva" action per row that deactivates that subscription (the
/// billing service then skips it) after a confirmation prompt.
class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();
  late Future<List<Subscription>> _subscriptionsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _subscriptionsFuture = _subscriptionRepository.getAll();
    });
  }

  Future<void> _openForm() async {
    final result = await showDialog<Subscription>(
      context: context,
      builder: (_) => const SubscriptionFormDialog(),
    );
    if (result != null) _reload();
  }

  Future<void> _deactivate(Subscription subscription) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disattivare l\'abbonamento?'),
        content: Text(
          'Da questo momento "${subscription.name}" non verrà più '
          'addebitato automaticamente.',
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

    await _subscriptionRepository.update(
      subscription.copyWith(isActive: false),
    );
    _reload();
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
              onPressed: _openForm,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Subscription>>(
              future: _subscriptionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Errore nel caricamento: ${snapshot.error}'),
                  );
                }

                final subscriptions = snapshot.data!;
                if (subscriptions.isEmpty) {
                  return const Center(
                    child: Text('Nessun abbonamento registrato'),
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
                              DataColumn(label: Text('Costo')),
                              DataColumn(label: Text('Periodicità')),
                              DataColumn(label: Text('Attivo')),
                              DataColumn(label: Text('Azioni')),
                            ],
                            rows: [
                              for (final subscription in subscriptions)
                                DataRow(
                                  cells: [
                                    DataCell(Text(subscription.name)),
                                    DataCell(
                                      Text(formatEuroAmount(subscription.cost)),
                                    ),
                                    DataCell(Text(subscription.type.label)),
                                    DataCell(
                                      subscription.isActive
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            )
                                          : const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                    ),
                                    DataCell(
                                      IconButton.outlined(
                                        icon: const Icon(
                                          Icons.power_settings_new,
                                        ),
                                        tooltip: 'Disattiva abbonamento',
                                        onPressed: subscription.isActive
                                            ? () => _deactivate(subscription)
                                            : null,
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
