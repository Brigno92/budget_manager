import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../BE/context/deposit_repository.dart';
import '../../BE/context/subscription_repository.dart';
import '../../BE/context/transaction_type_repository.dart';
import '../../BE/entities/deposit.dart';
import '../../BE/entities/subscription.dart';
import '../../BE/entities/subscription_type.dart';
import '../../BE/entities/transaction_type.dart';
import 'transaction_type_form_dialog.dart';

typedef _FormOptions = ({List<Deposit> deposits, List<TransactionType> types});

/// Dialog form to register a new [Subscription].
///
/// Pops with the created, id-populated [Subscription], or `null` if the
/// user cancels.
class SubscriptionFormDialog extends StatefulWidget {
  const SubscriptionFormDialog({super.key});

  @override
  State<SubscriptionFormDialog> createState() => _SubscriptionFormDialogState();
}

class _SubscriptionFormDialogState extends State<SubscriptionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _depositRepository = DepositRepository();
  final _transactionTypeRepository = TransactionTypeRepository();
  final _subscriptionRepository = SubscriptionRepository();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();

  late Future<_FormOptions> _optionsFuture;

  int? _selectedDepositId;
  int? _selectedTransactionTypeId;
  SubscriptionType _selectedType = SubscriptionType.monthly;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<_FormOptions> _loadOptions() async {
    final deposits = await _depositRepository.getAll();
    final types = await _transactionTypeRepository.getAll();
    return (deposits: deposits, types: types);
  }

  Future<void> _createTransactionType() async {
    final created = await showDialog<TransactionType>(
      context: context,
      builder: (_) => const TransactionTypeFormDialog(),
    );
    if (created == null) return;

    final options = await _optionsFuture;
    setState(() {
      _optionsFuture = Future.value((
        deposits: options.deposits,
        types: [...options.types, created]
          ..sort((a, b) => a.name.compareTo(b.name)),
      ));
      _selectedTransactionTypeId = created.id;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final cost = double.parse(_costController.text.replaceAll(',', '.'));
      final subscription = Subscription(
        name: _nameController.text.trim(),
        cost: cost.round(),
        type: _selectedType,
        creationDate: DateTime.now(),
        transactionTypeId: _selectedTransactionTypeId!,
        depositId: _selectedDepositId!,
      );
      final id = await _subscriptionRepository.create(subscription);
      if (mounted) {
        Navigator.of(context).pop(subscription.copyWith(id: id));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuovo abbonamento'),
      content: SizedBox(
        width: 400,
        child: FutureBuilder<_FormOptions>(
          future: _optionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text('Errore nel caricamento: ${snapshot.error}');
            }

            final options = snapshot.data!;
            _selectedDepositId ??= options.deposits.isNotEmpty
                ? options.deposits.first.id
                : null;
            _selectedTransactionTypeId ??= options.types.isNotEmpty
                ? options.types.first.id
                : null;

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Inserisci un nome'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Costo (€)',
                      prefixText: '€ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    validator: _validateCost,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SubscriptionType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'Periodicità'),
                    items: [
                      for (final type in SubscriptionType.values)
                        DropdownMenuItem(value: type, child: Text(type.label)),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedType = value ?? _selectedType),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedDepositId,
                    decoration: const InputDecoration(labelText: 'Deposito'),
                    items: [
                      for (final deposit in options.deposits)
                        DropdownMenuItem(
                          value: deposit.id,
                          child: Text(deposit.name),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedDepositId = value),
                    validator: (value) =>
                        value == null ? 'Seleziona un deposito' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedTransactionTypeId,
                          decoration: const InputDecoration(
                            labelText: 'Tipo di spesa',
                          ),
                          items: [
                            for (final type in options.types)
                              DropdownMenuItem(
                                value: type.id,
                                child: Text(type.name),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _selectedTransactionTypeId = value,
                          ),
                          validator: (value) =>
                              value == null ? 'Seleziona un tipo' : null,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Nuovo tipo di spesa',
                        icon: const Icon(Icons.add),
                        onPressed: _createTransactionType,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }
}

String? _validateCost(String? value) {
  if (value == null || value.trim().isEmpty) return 'Inserisci un costo';
  final parsed = double.tryParse(value.replaceAll(',', '.'));
  if (parsed == null || parsed <= 0) return 'Costo non valido';
  return null;
}
