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
    );
  }

  // ➕ دالة حقن البيانات (تستخدم للاستيراد وللإضافة اليدوية معاً)
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('timeline', data);
  }

  // 🔄 دالة تحديث بيانات فرد يدوياً بناءً على الرقم العسكري والشهر والسنة
  static Future<int> updatePersonStatus(String number, String month, String year, Map<String, dynamic> newData) async {
    final db = await database;
    return db.update(
      'timeline',
      newData,
      where: 'number = ? AND month = ? AND year = ?',
      whereArgs: [number, month, year],
    );
  }

  // ❌ دالة حذف فرد محدد من شهر محدد يدوياً
  static Future<int> deletePersonFromMonth(String number, String month, String year) async {
    final db = await database;
    return db.delete(
      'timeline',
      where: 'number = ? AND month = ? AND year = ?',
      whereArgs: [number, month, year],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;
    return db.query('timeline', orderBy: 'id DESC');
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

  static Future<void> deleteMonthData(String month, String year) async {
    final db = await database;
    await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  static Future<void> markMonthImported(String month, String year) async {
    final db = await database;
    await db.insert('imported_months', {
      'month': month,
      'year': year,
      'imported_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getImportedMonths() async {
    final db = await database;
    return db.query('imported_months', orderBy: 'id DESC');
  }
}

