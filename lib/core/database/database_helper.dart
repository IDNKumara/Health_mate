import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/health_records/models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('healthmate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE health_records (
        id $idType,
        date $textType,
        steps $intType,
        calories $intType,
        water $intType
      )
    ''');

    // Insert dummy records for testing
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    final now = DateTime.now();
    final dummyRecords = [
      HealthRecord(
        date: now.toIso8601String().split('T')[0],
        steps: 8500,
        calories: 450,
        water: 2000,
      ),
      HealthRecord(
        date: now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
        steps: 10200,
        calories: 520,
        water: 2500,
      ),
      HealthRecord(
        date: now.subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
        steps: 6800,
        calories: 380,
        water: 1800,
      ),
      HealthRecord(
        date: now.subtract(const Duration(days: 3)).toIso8601String().split('T')[0],
        steps: 12000,
        calories: 600,
        water: 3000,
      ),
      HealthRecord(
        date: now.subtract(const Duration(days: 4)).toIso8601String().split('T')[0],
        steps: 9500,
        calories: 480,
        water: 2200,
      ),
    ];

    for (var record in dummyRecords) {
      await db.insert('health_records', record.toMap());
    }
  }

  // CREATE
  Future<int> insertRecord(HealthRecord record) async {
    final db = await instance.database;
    return await db.insert('health_records', record.toMap());
  }

  // READ ALL
  Future<List<HealthRecord>> getAllRecords() async {
    final db = await instance.database;
    final result = await db.query(
      'health_records',
      orderBy: 'date DESC',
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // READ BY DATE
  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // READ SINGLE RECORD
  Future<HealthRecord?> getRecord(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return HealthRecord.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateRecord(HealthRecord record) async {
    final db = await instance.database;
    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // DELETE
  Future<int> deleteRecord(int id) async {
    final db = await instance.database;
    return await db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GET TODAY'S RECORDS
  Future<List<HealthRecord>> getTodayRecords() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return await getRecordsByDate(today);
  }

  // SEARCH BY DATE RANGE
  Future<List<HealthRecord>> searchRecordsByDateRange(
      String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.query(
      'health_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}