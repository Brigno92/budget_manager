import 'deposit.dart';
import 'transaction_type.dart';

/// A single movement of money on a [Deposit], classified by a [TransactionType].
class Transaction {
  final int? id;
  final int transactionTypeId;
  final TransactionType? type;
  final int depositId;
  final Deposit? deposit;
  final DateTime transactionDate;
  final int amount;
  final bool isPositive;

  const Transaction({
    this.id,
    required this.transactionTypeId,
    this.type,
    required this.depositId,
    this.deposit,
    required this.transactionDate,
    required this.amount,
    this.isPositive = false,
  });

  Transaction copyWith({
    int? id,
    int? transactionTypeId,
    TransactionType? type,
    int? depositId,
    Deposit? deposit,
    DateTime? transactionDate,
    int? amount,
    bool? isPositive,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionTypeId: transactionTypeId ?? this.transactionTypeId,
      type: type ?? this.type,
      depositId: depositId ?? this.depositId,
      deposit: deposit ?? this.deposit,
      transactionDate: transactionDate ?? this.transactionDate,
      amount: amount ?? this.amount,
      isPositive: isPositive ?? this.isPositive,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'transaction_type_id': transactionTypeId,
      'deposit_id': depositId,
      'transaction_date': transactionDate.toIso8601String(),
      'amount': amount,
      'is_positive': isPositive ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, Object?> map) {
    return Transaction(
      id: map['id'] as int?,
      transactionTypeId: map['transaction_type_id'] as int,
      depositId: map['deposit_id'] as int,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      amount: map['amount'] as int,
      isPositive: (map['is_positive'] as int) == 1,
    );
  }
}
