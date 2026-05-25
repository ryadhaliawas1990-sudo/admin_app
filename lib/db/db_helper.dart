import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timeline.db');

    return await openDatabase(
      path,
      version: 2, // 🔴 مهم: رفع النسخة
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute("DROP TABLE IF EXISTS timeline");
        await _createTables(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE timeline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        name TEXT,
        rank TEXT,
        unit TEXT,
        status TEXT,
        month TEXT,
        year TEXT
      )
    ''');
  }

  // =========================
  // INSERT (مقوى ضد null)
  // =========================
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;

    return await db.insert(
      'timeline',
      {
        "number": (data["number"] ?? "").toString(),
        "name": (data["name"] ?? "").toString(),
        "rank": (data["rank"] ?? "").toString(),
        "unit": (data["unit"] ?? "").toString(),
        "status": (data["status"] ?? "").toString(),
        "month": (data["month"] ?? "").toString(),
        "year": (data["year"] ?? "").toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateTimeline(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'timeline',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getPersonTimeline(String number) async {
    final db = await database;

    return await db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
      orderBy: 'CAST(year AS INTEGER) DESC, CAST(month AS INTEGER) DESC',
    );
  }

  static Future<int> deleteMonth(String month, String year) async {
    final db = await database;

    return await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  static Future<int> deleteImportedMonth(String month, String year) async {
    return deleteMonth(month, year);
  }

  static Future<List<Map<String, dynamic>>> getImportedMonths() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT month, year, COUNT(*) as total
      FROM timeline
      GROUP BY month, year
      ORDER BY CAST(year AS INTEGER) DESC, CAST(month AS INTEGER) DESC
    ''');
  }

  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;

    return await db.query(
      'timeline',
      orderBy: 'CAST(year AS INTEGER) DESC, CAST(month AS INTEGER) DESC',
    );
  }

  static Future<int> deleteTimeline(int id) async {
    final db = await database;

    return await db.delete(
      'timeline',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('timeline');
  }
}
