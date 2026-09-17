import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../BE/context/deposit_repository.dart';
import '../../BE/context/transaction_repository.dart';
import '../../BE/context/transaction_type_repository.dart';
import '../../BE/entities/deposit.dart';
import '../../BE/entities/transaction.dart';
import '../../BE/entities/transaction_type.dart';
import 'transaction_type_form_dialog.dart';

typedef _FormOptions = ({List<Deposit> deposits, List<TransactionType> types});

/// Dialog form to register a new expense [Transaction].
///
/// Shown from the app shell's "add" FAB. On save, it creates the
/// transaction through [TransactionRepository] and pops with `true`.
class RegisterTransactionDialog extends StatefulWidget {
  const RegisterTransactionDialog({super.key});

  @override
  State<RegisterTransactionDialog> createState() =>
      _RegisterTransactionDialogState();
}

class _RegisterTransactionDialogState extends State<RegisterTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _depositRepository = DepositRepository();
  final _transactionTypeRepository = TransactionTypeRepository();
  final _transactionRepository = TransactionRepository();
  final _amountController = TextEditingController();

  late Future<_FormOptions> _optionsFuture;

  int? _selectedDepositId;
  int? _selectedTransactionTypeId;
  DateTime _selectedDate = DateTime.now();
  bool _isIncome = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<_FormOptions> _loadOptions() async {
    final deposits = await _depositRepository.getAll();
    final types = await _transactionTypeRepository.getAll();
    return (deposits: deposits, types: types);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
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
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      await _transactionRepository.create(
        Transaction(
          transactionTypeId: _selectedTransactionTypeId!,
          depositId: _selectedDepositId!,
          transactionDate: _selectedDate,
          amount: amount.round(),
          isPositive: _isIncome,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registra transazione'),
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
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Data'),
                      child: Text(_formatDate(_selectedDate)),
                    ),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Importo (€)',
                      prefixText: '€ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    validator: _validateAmount,
                  ),
                  CheckboxListTile(
                    value: _isIncome,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('È un guadagno'),
                    onChanged: (value) =>
                        setState(() => _isIncome = value ?? false),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
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

String? _validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Inserisci un importo';
  final parsed = double.tryParse(value.replaceAll(',', '.'));
  if (parsed == null || parsed <= 0) return 'Importo non valido';
  return null;
}

String _formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
