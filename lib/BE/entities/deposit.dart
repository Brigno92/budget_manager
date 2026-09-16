/// A deposit (bank account, cash wallet, ...) that holds transactions.
class Deposit {
  final int? id;
  final String name;
  final String color;
  final int account;
  final bool principal;

  const Deposit({
    this.id,
    required this.name,
    required this.color,
    required this.account,
    required this.principal,
  });

  Deposit copyWith({
    int? id,
    String? name,
    String? color,
    int? account,
    bool? principal,
  }) {
    return Deposit(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      account: account ?? this.account,
      principal: principal ?? this.principal,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'color': color,
      'account': account,
      'principal': principal ? 1 : 0,
    };
  }

  factory Deposit.fromMap(Map<String, Object?> map) {
    return Deposit(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String,
      account: map['account'] as int,
      principal: (map['principal'] as int) == 1,
    );
  }
}
