import '../entities/deposit.dart';
import 'app_database.dart';

/// CRUD access to the `deposits` table.
class DepositRepository {
  static const String table = 'deposits';

  final AppDatabase _appDatabase;

  DepositRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase();

  Future<int> create(Deposit deposit) async {
    final db = await _appDatabase.database;
    return db.insert(table, deposit.toMap());
  }

  Future<List<Deposit>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, orderBy: 'name ASC');
    return rows.map(Deposit.fromMap).toList();
  }

  Future<Deposit?> getById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Deposit.fromMap(rows.first);
  }

  Future<int> update(Deposit deposit) async {
    assert(deposit.id != null, 'Cannot update a Deposit without an id');
    final db = await _appDatabase.database;
    return db.update(
      table,
      deposit.toMap(),
      where: 'id = ?',
      whereArgs: [deposit.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _appDatabase.database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
