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

    final path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 2,

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

  // INSERT
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('timeline', data);
  }

  // GET ALL
  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;
    return db.query('timeline');
  }

  // PERSON
  static Future<List<Map<String, dynamic>>> getPersonTimeline(String number) async {
    final db = await database;
    return db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
    );
  }

  // DELETE MONTH (استبدال)
  static Future<void> deleteMonthData(String month, String year) async {
    final db = await database;

    await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    await db.delete(
      'imported_months',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  // MARK IMPORTED
  static Future<void> markMonthImported(String month, String year) async {
    final db = await database;

    await db.insert('imported_months', {
      'month': month,
      'year': year,
      'imported_at': DateTime.now().toIso8601String(),
    });
  }

  // CHECK
  static Future<bool> isMonthImported(String month, String year) async {
    final db = await database;

    final result = await db.query(
      'imported_months',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    return result.isNotEmpty;
  }
}
