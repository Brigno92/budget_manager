import '../entities/transaction_type.dart';
import 'app_database.dart';

/// CRUD access to the `transaction_types` table.
class TransactionTypeRepository {
  static const String table = 'transaction_types';

  final AppDatabase _appDatabase;

  TransactionTypeRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase();

  Future<int> create(TransactionType type) async {
    final db = await _appDatabase.database;
    return db.insert(table, type.toMap());
  }

  Future<List<TransactionType>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, orderBy: 'name ASC');
    return rows.map(TransactionType.fromMap).toList();
  }

  Future<TransactionType?> getById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return TransactionType.fromMap(rows.first);
  }

  Future<int> update(TransactionType type) async {
    assert(type.id != null, 'Cannot update a TransactionType without an id');
    final db = await _appDatabase.database;
    return db.update(
      table,
      type.toMap(),
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _appDatabase.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
