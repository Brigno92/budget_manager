import '../entities/subscription.dart';
import 'app_database.dart';
import 'deposit_repository.dart';
import 'transaction_type_repository.dart';

/// CRUD access to the `subscriptions` table.
///
/// Reads hydrate [Subscription.transactionType] and [Subscription.deposit]
/// by looking them up through [TransactionTypeRepository] and
/// [DepositRepository].
class SubscriptionRepository {
  static const String table = 'subscriptions';

  final AppDatabase _appDatabase;
  final TransactionTypeRepository _transactionTypeRepository;
  final DepositRepository _depositRepository;

  SubscriptionRepository({
    AppDatabase? appDatabase,
    TransactionTypeRepository? transactionTypeRepository,
    DepositRepository? depositRepository,
  }) : _appDatabase = appDatabase ?? AppDatabase(),
       _transactionTypeRepository =
           transactionTypeRepository ?? TransactionTypeRepository(),
       _depositRepository = depositRepository ?? DepositRepository();

  Future<int> create(Subscription subscription) async {
    final db = await _appDatabase.database;
    return db.insert(table, subscription.toMap());
  }

  Future<List<Subscription>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, orderBy: 'name ASC');
    return Future.wait(rows.map(_hydrate));
  }

  Future<Subscription?> getById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _hydrate(rows.first);
  }

  Future<int> update(Subscription subscription) async {
    assert(
      subscription.id != null,
      'Cannot update a Subscription without an id',
    );
    final db = await _appDatabase.database;
    return db.update(
      table,
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _appDatabase.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Subscription> _hydrate(Map<String, Object?> row) async {
    final subscription = Subscription.fromMap(row);
    final transactionType = await _transactionTypeRepository.getById(
      subscription.transactionTypeId,
    );
    final deposit = await _depositRepository.getById(subscription.depositId);
    return subscription.copyWith(
      transactionType: transactionType,
      deposit: deposit,
    );
  }
}
