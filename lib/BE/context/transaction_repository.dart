import '../entities/transaction.dart';
import 'app_database.dart';
import 'deposit_repository.dart';
import 'transaction_type_repository.dart';

/// CRUD access to the `transactions` table.
///
/// Reads hydrate [Transaction.type] and [Transaction.deposit] by looking them
/// up through [TransactionTypeRepository] and [DepositRepository].
class TransactionRepository {
  static const String table = 'transactions';

  final AppDatabase _appDatabase;
  final DepositRepository _depositRepository;
  final TransactionTypeRepository _transactionTypeRepository;

  TransactionRepository({
    AppDatabase? appDatabase,
    DepositRepository? depositRepository,
    TransactionTypeRepository? transactionTypeRepository,
  }) : _appDatabase = appDatabase ?? AppDatabase(),
       _depositRepository = depositRepository ?? DepositRepository(),
       _transactionTypeRepository =
           transactionTypeRepository ?? TransactionTypeRepository();

  Future<int> create(Transaction transaction) async {
    final db = await _appDatabase.database;
    return db.insert(table, transaction.toMap());
  }

  Future<List<Transaction>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, orderBy: 'transaction_date DESC');
    return Future.wait(rows.map(_hydrate));
  }

  Future<List<Transaction>> getByDeposit(int depositId) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      table,
      where: 'deposit_id = ?',
      whereArgs: [depositId],
      orderBy: 'transaction_date DESC',
    );
    return Future.wait(rows.map(_hydrate));
  }

  Future<Transaction?> getById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _hydrate(rows.first);
  }

  Future<int> update(Transaction transaction) async {
    assert(transaction.id != null, 'Cannot update a Transaction without an id');
    final db = await _appDatabase.database;
    return db.update(
      table,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _appDatabase.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Transaction> _hydrate(Map<String, Object?> row) async {
    final transaction = Transaction.fromMap(row);
    final type = await _transactionTypeRepository.getById(
      transaction.transactionTypeId,
    );
    final deposit = await _depositRepository.getById(transaction.depositId);
    return transaction.copyWith(type: type, deposit: deposit);
  }
}
