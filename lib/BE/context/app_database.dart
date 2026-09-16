import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton wrapper around the app's SQLite database.
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'budget_manager.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createDepositsTable(db);
    await _createTransactionTypesTable(db);
    await _createTransactionsTable(db);
    await _createSubscriptionsTable(db);
  }

  Future<void> _createDepositsTable(Database db) async {
    await db.execute('''
      CREATE TABLE deposits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        account INTEGER NOT NULL,
        principal INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createTransactionTypesTable(Database db) async {
    await db.execute('''
      CREATE TABLE transaction_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_type_id INTEGER NOT NULL,
        deposit_id INTEGER NOT NULL,
        transaction_date TEXT NOT NULL,
        amount INTEGER NOT NULL,
        is_positive INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (transaction_type_id) REFERENCES transaction_types (id) ON DELETE RESTRICT,
        FOREIGN KEY (deposit_id) REFERENCES deposits (id) ON DELETE RESTRICT
      )
    ''');
  }

  Future<void> _createSubscriptionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost INTEGER NOT NULL,
        type TEXT NOT NULL,
        creation_date TEXT NOT NULL,
        transaction_type_id INTEGER NOT NULL,
        FOREIGN KEY (transaction_type_id) REFERENCES transaction_types (id) ON DELETE RESTRICT
      )
    ''');
  }
}
