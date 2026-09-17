import 'package:flutter/material.dart';

import '../../BE/context/transaction_type_repository.dart';
import '../../BE/entities/transaction_type.dart';

/// Dialog form to create or edit a [TransactionType].
///
/// With [existing] left null it creates a new type; otherwise it edits that
/// type in place. Pops with the created/updated, id-populated
/// [TransactionType], or `null` if the user cancels.
class TransactionTypeFormDialog extends StatefulWidget {
  final TransactionType? existing;

  const TransactionTypeFormDialog({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  State<TransactionTypeFormDialog> createState() =>
      _TransactionTypeFormDialogState();
}

class _TransactionTypeFormDialogState extends State<TransactionTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _transactionTypeRepository = TransactionTypeRepository();
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final existing = widget.existing;
      final TransactionType saved;
      if (existing == null) {
        final type = TransactionType(name: _nameController.text.trim());
        final id = await _transactionTypeRepository.create(type);
        saved = type.copyWith(id: id);
      } else {
        saved = existing.copyWith(name: _nameController.text.trim());
        await _transactionTypeRepository.update(saved);
      }
      if (mounted) Navigator.of(context).pop(saved);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Dettaglio tipo' : 'Nuovo tipo'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Inserisci un nome'
              : null,
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
