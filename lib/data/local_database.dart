import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CalculationRecord {
  final int? id;
  final double numberA;
  final double numberB;
  final double result;
  final String formula;
  final DateTime timestamp;

  CalculationRecord({
    this.id,
    required this.numberA,
    required this.numberB,
    required this.result,
    required this.formula,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number_a': numberA,
      'number_b': numberB,
      'result': result,
      'formula': formula,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static CalculationRecord fromMap(Map<String, dynamic> map) {
    return CalculationRecord(
      id: map['id'],
      numberA: map['number_a'],
      numberB: map['number_b'],
      result: map['result'],
      formula: map['formula'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class LocalDatabase {
  static Database? _database;
  static const String _dbName = 'calculations.db';
  static const String _tableName = 'calculation_history';

  // Singleton паттерн
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Инициализация базы данных
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Создание таблицы
  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number_a REAL NOT NULL,
        number_b REAL NOT NULL,
        result REAL NOT NULL,
        formula TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Добавить запись
  static Future<int> insertCalculation(CalculationRecord record) async {
    final db = await database;
    return await db.insert(_tableName, record.toMap());
  }

  // Получить все записи (последние сначала)
  static Future<List<CalculationRecord>> getAllCalculations() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => CalculationRecord.fromMap(maps[i]));
  }

  // Удалить запись по ID
  static Future<void> deleteCalculation(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Очистить всю историю
  static Future<void> clearHistory() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Получить количество записей
  static Future<int> getCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tableName')) ?? 0;
  }

  // Закрыть базу данных
  static Future<void> close() async {
    final db = await database;
    await db.close();
  }
}