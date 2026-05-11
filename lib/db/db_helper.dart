import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../core/app_refresher.dart';

class DBHelper {
  static Database? _db;

  // =========================
  // 📌 DATABASE INIT
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

      // 🟢 إنشاء أول مرة
      onCreate: (db, version) async {
        await _createTables(db);
      },

      // 🟡 ترقيات
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE people ADD COLUMN month TEXT",
          );
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reports(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              monthA TEXT,
              monthB TEXT,
              filePath TEXT,
              createdAt TEXT
            )
          ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS system_meta(
              id INTEGER PRIMARY KEY,
              lastActivity TEXT
            )
          ''');
        }
      },
    );
  }

  // =========================
  // 🏗️ CREATE TABLES (CLEAN)
  // =========================

  static Future<void> _createTables(Database db) async {
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

    await db.execute('''
      CREATE TABLE system_meta(
        id INTEGER PRIMARY KEY,
        lastActivity TEXT
      )
    ''');
  }

  // =========================
  // 🧠 SYSTEM ACTIVITY
  // =========================

  static Future<void> updateLastActivity() async {
    final db = await database;

    await db.insert(
      'system_meta',
      {
        'id': 1,
        'lastActivity': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getLastActivity() async {
    final db = await database;

    final res = await db.query(
      'system_meta',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return res.first['lastActivity'] as String;
    }

    return null;
  }

  // =========================
  // 👥 PEOPLE
  // =========================

  static Future<int> insertPerson(Map<String, dynamic> data) async {
    final db = await database;

    final res = await db.insert('people', data);

    await updateLastActivity();
    AppRefresher.refresh();

    return res;
  }

  static Future<List<Map<String, dynamic>>> getPeople() async {
    final db = await database;

    return await db.query(
      'people',
      orderBy: 'id DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> getByMonth(String month) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'month = ?',
      whereArgs: [month],
      orderBy: 'id DESC',
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

    await updateLastActivity();
    AppRefresher.refresh();

    return res;
  }

  static Future<void> deletePerson(int id) async {
    final db = await database;

    await db.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );

    await updateLastActivity();
    AppRefresher.refresh();
  }

  // =========================
  // 📁 REPORTS
  // =========================

  static Future<int> insertReport(Map<String, dynamic> data) async {
    final db = await database;

    final res = await db.insert('reports', {
      "title": data["title"],
      "monthA": data["monthA"],
      "monthB": data["monthB"],
      "filePath": data["filePath"],
      "createdAt": DateTime.now().toIso8601String(),
    });

    await updateLastActivity();
    AppRefresher.refresh();

    return res;
  }

  static Future<List<Map<String, dynamic>>> getReports() async {
    final db = await database;

    return await db.query(
      'reports',
      orderBy: 'id DESC',
    );
  }

  static Future<void> deleteReport(int id) async {
    final db = await database;

    await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    await updateLastActivity();
    AppRefresher.refresh();
  }

  // =========================
  // 📊 MONTHS
  // =========================

  static Future<List<Map<String, dynamic>>> getMonths() async {
    final db = await database;

    return await db.rawQuery(
      'SELECT DISTINCT month FROM people ORDER BY month DESC',
    );
  }
}
