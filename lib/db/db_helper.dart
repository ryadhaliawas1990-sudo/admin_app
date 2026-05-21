import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'admin_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        // جدول الأفراد
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

        // جدول تتبع الاستيراد (مهم جدًا لإصلاح import_screen)
        await db.execute('''
          CREATE TABLE imported_months (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            month TEXT,
            year TEXT,
            imported_at TEXT
          )
        ''');
      },
    );
  }

  // =========================
  // INSERT timeline
  // =========================
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('timeline', data);
  }

  // =========================
  // UPDATE timeline
  // =========================
  static Future<int> updateTimeline(Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'timeline',
      data,
      where: 'number = ? AND month = ? AND year = ?',
      whereArgs: [data['number'], data['month'], data['year']],
    );
  }

  // =========================
  // GET PERSON TIMELINE
  // =========================
  static Future<List<Map<String, dynamic>>> getPersonTimeline(
      String number) async {
    final db = await database;

    return await db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
      orderBy: 'year ASC, month ASC',
    );
  }

  // =========================
  // DELETE MONTH (timeline)
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
  // GET IMPORTED MONTHS
  // =========================
  static Future<List<Map<String, dynamic>>> getImportedMonths() async {
    final db = await database;

    return await db.query(
      'imported_months',
      orderBy: 'year DESC, month DESC',
    );
  }

  // =========================
  // MARK MONTH IMPORTED
  // =========================
  static Future<void> markMonthImported(String month, String year) async {
    final db = await database;

    await db.insert('imported_months', {
      'month': month,
      'year': year,
      'imported_at': DateTime.now().toIso8601String(),
    });
  }

  // =========================
  // DELETE MONTH DATA (compatibility)
  // =========================
  static Future<void> deleteMonthData(String month, String year) async {
    final db = await database;

    await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }
}
