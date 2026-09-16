import 'subscription_type.dart';
import 'transaction_type.dart';

/// A recurring cost (e.g. a streaming service) classified by a [TransactionType].
class Subscription {
  final int? id;
  final String name;
  final int cost;
  final SubscriptionType type;
  final DateTime creationDate;
  final int transactionTypeId;
  final TransactionType? transactionType;

  const Subscription({
    this.id,
    required this.name,
    required this.cost,
    required this.type,
    required this.creationDate,
    required this.transactionTypeId,
    this.transactionType,
  });

  Subscription copyWith({
    int? id,
    String? name,
    int? cost,
    SubscriptionType? type,
    DateTime? creationDate,
    int? transactionTypeId,
    TransactionType? transactionType,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      type: type ?? this.type,
      creationDate: creationDate ?? this.creationDate,
      transactionTypeId: transactionTypeId ?? this.transactionTypeId,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'cost': cost,
      'type': type.name,
      'creation_date': creationDate.toIso8601String(),
      'transaction_type_id': transactionTypeId,
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
    );
  }
}
