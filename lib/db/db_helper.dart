import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // =========================
  // 📌 INIT DATABASE
  // =========================

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'admin.db');

    return await openDatabase(
      path,
      version: 4,

      onCreate: (db, version) async {

        // 👥 PEOPLE
        await db.execute('''
          CREATE TABLE people(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            number TEXT,
            rank TEXT,
            unit TEXT,
            status TEXT,
            month TEXT
          )
        ''');

        // 📁 REPORTS
        await db.execute('''
          CREATE TABLE reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            monthA TEXT,
            monthB TEXT,
            filePath TEXT,
            createdAt TEXT
          )
        ''');

        // 🧠 LOGS (سجل النشاط)
        await db.execute('''
          CREATE TABLE logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  // =========================
  // 🧠 LOG SYSTEM
  // =========================

  static Future<void> addLog(String action) async {
    final db = await database;

    await db.insert('logs', {
      'action': action,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await database;

    return await db.query(
      'logs',
      orderBy: 'id DESC',
    );
  }

  // =========================
  // 👥 PEOPLE
  // =========================

  static Future<int> insertPerson(Map<String, dynamic> data) async {
    final db = await database;
    final res = await db.insert('people', data);

    await addLog("تم إضافة موظف");

    return res;
  }

  static Future<List<Map<String, dynamic>>> getPeople() async {
    final db = await database;
    return await db.query('people', orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> getByMonth(String month) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'month = ?',
      whereArgs: [month],
    );
  }

  static Future<List<Map<String, dynamic>>> searchPeople(String query) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'name LIKE ? OR number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  static Future<int> updatePerson(int id, Map<String, dynamic> data) async {
    final db = await database;

    final res = await db.update(
      'people',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );

    await addLog("تم تعديل موظف");

    return res;
  }

  static Future<void> deletePerson(int id) async {
    final db = await database;

    await db.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );

    await addLog("تم حذف موظف");
  }

  static Future<List<Map<String, dynamic>>> getMonths() async {
    final db = await database;

    return await db.rawQuery(
      'SELECT DISTINCT month FROM people ORDER BY month DESC',
    );
  }

  // =========================
  // 📁 REPORTS
  // =========================

  static Future<int> insertReport(Map<String, dynamic> data) async {
    final db = await database;
    final res = await db.insert('reports', data);

    await addLog("تم إنشاء تقرير");

    return res;
  }

  static Future<List<Map<String, dynamic>>> getReports() async {
    final db = await database;

    return await db.query('reports', orderBy: 'id DESC');
  }

  static Future<void> deleteReport(int id) async {
    final db = await database;

    await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    await addLog("تم حذف تقرير");
  }
}
