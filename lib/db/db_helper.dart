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

    return openDatabase(
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

      onUpgrade: (db, oldVersion, newVersion) async {

        await db.execute('DROP TABLE IF EXISTS timeline');
        await db.execute('DROP TABLE IF EXISTS imported_months');

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

  // =========================
  // TIMELINE
  // =========================

  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('timeline', data);
  }

  static Future<int> updateTimeline(int id, Map<String, dynamic> data) async {
    final db = await database;
    return db.update(
      'timeline',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteMonth(String month, String year) async {
    final db = await database;

    return db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  static Future<List<Map<String, dynamic>>> searchPeople(String query) async {
    final db = await database;

    return db.query(
      'timeline',
      where: 'number LIKE ? OR name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> getPersonTimeline(String number) async {
    final db = await database;

    return db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
      orderBy: 'year DESC, month DESC',
    );
  }

  // =========================
  // STATUS DASHBOARD
  // =========================

  static Future<List<Map<String, dynamic>>> getStatusStats() async {
    final db = await database;

    return db.rawQuery('''
      SELECT TRIM(status) as status, COUNT(*) as count
      FROM timeline
      WHERE status IS NOT NULL AND status != ''
      GROUP BY TRIM(status)
      ORDER BY count DESC
    ''');
  }

  // =========================
  // IMPORTED MONTHS (NEW IMPORTANT PART)
  // =========================

  static Future<int> insertImportedMonth(String month, String year) async {
    final db = await database;

    return db.insert('imported_months', {
      'month': month,
      'year': year,
      'imported_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getImportedMonths() async {
    final db = await database;

    return db.query(
      'imported_months',
      orderBy: 'year DESC, month DESC',
    );
  }

  static Future<int> deleteImportedMonth(String month, String year) async {
    final db = await database;

    return db.delete(
      'imported_months',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }
}
