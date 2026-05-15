import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  static Database? _db;

  // =========================
  // فتح قاعدة البيانات
  // =========================
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
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
      },
    );
  }

  // =========================
  // إدخال سجل
  // =========================
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('timeline', data);
  }

  // =========================
  // جلب كل البيانات
  // =========================
  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;
    return await db.query('timeline');
  }

  // =========================
  // جلب فرد واحد عبر الرقم
  // =========================
  static Future<List<Map<String, dynamic>>> getPersonTimeline(String number) async {
    final db = await database;
    return await db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
    );
  }
}
