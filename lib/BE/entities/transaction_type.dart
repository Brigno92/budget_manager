/// A category used to classify transactions and subscriptions (e.g. "Groceries", "Salary").
class TransactionType {
  final int? id;
  final String name;

  const TransactionType({this.id, required this.name});

  TransactionType copyWith({int? id, String? name}) {
    return TransactionType(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, Object?> toMap() {
    return {'name': name};
  }

  factory TransactionType.fromMap(Map<String, Object?> map) {
    return TransactionType(id: map['id'] as int?, name: map['name'] as String);
  }
}
