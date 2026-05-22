import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {

  static Database? _db;

  // =========================
  // قاعدة البيانات
  // =========================

  static Future<Database> get database async {

    if (_db != null) {
      return _db!;
    }

    _db = await initDB();

    return _db!;
  }

  // =========================
  // إنشاء قاعدة البيانات
  // =========================

  static Future<Database> initDB() async {

    final dbPath =
        await getDatabasesPath();

    final path =
        join(dbPath, 'timeline.db');

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
  // إضافة سجل
  // =========================

  static Future<int> insertTimeline(
    Map<String, dynamic> data,
  ) async {

    final db = await database;

    return await db.insert(

      'timeline',

      data,

      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // =========================
  // تحديث سجل
  // =========================

  static Future<int> updateTimeline(
    int id,
    Map<String, dynamic> data,
  ) async {

    final db = await database;

    return await db.update(

      'timeline',

      data,

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // =========================
  // جلب سجل فرد
  // =========================

  static Future<List<Map<String, dynamic>>>
      getPersonTimeline(
    String number,
  ) async {

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
  // حذف شهر كامل
  // =========================

  static Future<int> deleteMonth(
    String month,
    String year,
  ) async {

    final db = await database;

    return await db.delete(

      'timeline',

      where: 'month = ? AND year = ?',

      whereArgs: [
        month,
        year,
      ],
    );
  }

  // =========================
  // جلب الأشهر المستوردة
  // =========================

  static Future<List<Map<String, dynamic>>>
      getImportedMonths() async {

    final db = await database;

    return await db.rawQuery('''

      SELECT

        month,
        year,

        COUNT(*) as total

      FROM timeline

      GROUP BY month, year

      ORDER BY

        CAST(year AS INTEGER) DESC,

        CAST(month AS INTEGER) DESC

    ''');
  }

  // =========================
  // حذف شهر مستورد
  // =========================

  static Future<int> deleteImportedMonth(
    String month,
    String year,
  ) async {

    final db = await database;

    return await db.delete(

      'timeline',

      where: 'month = ? AND year = ?',

      whereArgs: [
        month,
        year,
      ],
    );
  }

  // =========================
  // جلب كل البيانات
  // =========================

  static Future<List<Map<String, dynamic>>>
      getAllTimeline() async {

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
  // حذف سجل
  // =========================

  static Future<int> deleteTimeline(
    int id,
  ) async {

    final db = await database;

    return await db.delete(

      'timeline',

      where: 'id = ?',

      whereArgs: [id],
    );
  }

  // =========================
  // حذف جميع البيانات
  // =========================

  static Future<void> clearDatabase() async {

    final db = await database;

    await db.delete('timeline');
  }
}
