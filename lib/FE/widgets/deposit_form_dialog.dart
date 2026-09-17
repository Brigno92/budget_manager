import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../BE/context/deposit_repository.dart';
import '../../BE/entities/deposit.dart';
import 'color_preview_box.dart';
import 'deposit_color.dart';

/// Dialog form to create or edit a [Deposit].
///
/// With [existing] left null it creates a new deposit, asking for its
/// initial account balance. Editing an existing deposit can only change its
/// name and color: the balance and "principal" flag are preserved as-is.
///
/// Pops with the created/updated, id-populated [Deposit], or `null` if the
/// user cancels.
class DepositFormDialog extends StatefulWidget {
  final Deposit? existing;

  const DepositFormDialog({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  State<DepositFormDialog> createState() => _DepositFormDialogState();
}

class _DepositFormDialogState extends State<DepositFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _depositRepository = DepositRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late Color _color;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.account.toString(),
    );
    _color = existing != null ? parseDepositColor(existing.color) : Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickColor() async {
    var pickedColor = _color;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Scegli un colore'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _color,
            onColorChanged: (color) => pickedColor = color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) setState(() => _color = pickedColor);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final existing = widget.existing;
      final Deposit saved;
      if (existing == null) {
        final amount = double.parse(
          _amountController.text.replaceAll(',', '.'),
        );
        final deposit = Deposit(
          name: _nameController.text.trim(),
          color: encodeDepositColor(_color),
          account: amount.round(),
          principal: false,
        );
        final id = await _depositRepository.create(deposit);
        saved = deposit.copyWith(id: id);
      } else {
        saved = existing.copyWith(
          name: _nameController.text.trim(),
          color: encodeDepositColor(_color),
        );
        await _depositRepository.update(saved);
      }
      if (mounted) Navigator.of(context).pop(saved);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Dettaglio deposito' : 'Nuovo deposito'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Inserisci un nome'
                    : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickColor,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Colore'),
                  child: Row(
                    children: [
                      ColorPreviewBox(color: _color),
                      const SizedBox(width: 8),
                      const Text('Tocca per cambiare'),
                    ],
                  ),
                ),
              ),
              if (!widget.isEditing) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Conto iniziale (€)',
                    prefixText: '€ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  validator: _validateInitialAmount,
                ),
              ],
            ],
          ),
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

String? _validateInitialAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Inserisci un importo';
  final parsed = double.tryParse(value.replaceAll(',', '.'));
  if (parsed == null || parsed < 0) return 'Importo non valido';
  return null;
}
