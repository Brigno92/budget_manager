import 'deposit.dart';
import 'subscription_type.dart';
import 'transaction_type.dart';

/// A recurring cost (e.g. a streaming service) classified by a
/// [TransactionType] and billed against a [Deposit].
class Subscription {
  final int? id;
  final String name;
  final int cost;
  final SubscriptionType type;
  final DateTime creationDate;
  final int transactionTypeId;
  final TransactionType? transactionType;
  final int depositId;
  final Deposit? deposit;
  final bool isActive;

  /// The date this subscription was last charged, or null if it never has
  /// been. Used to determine when the next payment is due.
  final DateTime? lastBilledDate;

  const Subscription({
    this.id,
    required this.name,
    required this.cost,
    required this.type,
    required this.creationDate,
    required this.transactionTypeId,
    this.transactionType,
    required this.depositId,
    this.deposit,
    this.isActive = true,
    this.lastBilledDate,
  });

  Subscription copyWith({
    int? id,
    String? name,
    int? cost,
    SubscriptionType? type,
    DateTime? creationDate,
    int? transactionTypeId,
    TransactionType? transactionType,
    int? depositId,
    Deposit? deposit,
    bool? isActive,
    DateTime? lastBilledDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      type: type ?? this.type,
      creationDate: creationDate ?? this.creationDate,
      transactionTypeId: transactionTypeId ?? this.transactionTypeId,
      transactionType: transactionType ?? this.transactionType,
      depositId: depositId ?? this.depositId,
      deposit: deposit ?? this.deposit,
      isActive: isActive ?? this.isActive,
      lastBilledDate: lastBilledDate ?? this.lastBilledDate,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'cost': cost,
      'type': type.name,
      'creation_date': creationDate.toIso8601String(),
      'transaction_type_id': transactionTypeId,
      'deposit_id': depositId,
      'is_active': isActive ? 1 : 0,
      'last_billed_date': lastBilledDate?.toIso8601String(),
    };
  }

  factory Subscription.fromMap(Map<String, Object?> map) {
    return Subscription(
      id: map['id'] as int?,
      name: map['name'] as String,
      cost: map['cost'] as int,
      type: SubscriptionType.fromName(map['type'] as String),
      creationDate: DateTime.parse(map['creation_date'] as String),
      transactionTypeId: map['transaction_type_id'] as int,
      depositId: map['deposit_id'] as int,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      lastBilledDate: map['last_billed_date'] != null
          ? DateTime.parse(map['last_billed_date'] as String)
          : null,
    );
  }
}
