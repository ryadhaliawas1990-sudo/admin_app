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
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
  }

  // =========================
  // INSERT
  // =========================
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;

    return await db.insert(
      'timeline',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =========================
  // UPDATE
  // =========================
  static Future<int> updateTimeline(
      int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'timeline',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // GET PERSON
  // =========================
  static Future<List<Map<String, dynamic>>> getPersonTimeline(
      String number) async {
    final db = await database;

    return await db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
      orderBy: '''
        CAST(year AS INTEGER) DESC,
        CAST(month AS INTEGER) DESC
      ''',
    );
  }

  // =========================
  // DELETE MONTH (أساسي)
  // =========================
  static Future<int> deleteMonth(String month, String year) async {
    final db = await database;

    return await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  // =========================
  // ALIAS (حل أخطاء المشروع)
  // =========================
  static Future<int> deleteImportedMonth(
      String month, String year) async {
    return deleteMonth(month, year);
  }

  // =========================
  // GET MONTHS
  // =========================
  static Future<List<Map<String, dynamic>>> getImportedMonths() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT month, year, COUNT(*) as total
      FROM timeline
      GROUP BY month, year
      ORDER BY CAST(year AS INTEGER) DESC,
               CAST(month AS INTEGER) DESC
    ''');
  }

  // =========================
  // GET ALL
  // =========================
  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;

    return await db.query(
      'timeline',
      orderBy: '''
        CAST(year AS INTEGER) DESC,
        CAST(month AS INTEGER) DESC
      ''',
    );
  }

  // =========================
  // DELETE SINGLE
  // =========================
  static Future<int> deleteTimeline(int id) async {
    final db = await database;

    return await db.delete(
      'timeline',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // CLEAR ALL
  // =========================
  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('timeline');
  }
}
