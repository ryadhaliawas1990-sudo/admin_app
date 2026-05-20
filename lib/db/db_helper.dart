import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');

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

        await db.execute('''
          CREATE TABLE imported_months (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            month TEXT,
            year TEXT
          )
        ''');
      },
    );
  }

  // 🔵 INSERT
  static Future<void> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('timeline', data);
  }

  // 🔵 DELETE MONTH
  static Future<void> deleteMonthData(String month, String year) async {
    final db = await database;
    await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  // 🔵 MARK IMPORTED
  static Future<void> markMonthImported(String month, String year) async {
    final db = await database;
    await db.insert('imported_months', {
      'month': month,
      'year': year,
    });
  }

  // 🔵 DASHBOARD QUERIES
  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;
    return await db.query('timeline');
  }
}
