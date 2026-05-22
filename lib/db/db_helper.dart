import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  static Database? _db;

  static Future<Database> get database async {

    if (_db != null) {
      return _db!;
    }

    _db = await _initDB();

    return _db!;
  }

  static Future<Database> _initDB() async {

    final path = join(
      await getDatabasesPath(),
      'admin_app.db',
    );

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

      onUpgrade: (db, oldVersion, newVersion) async {

        // حذف الجداول القديمة وإعادة إنشائها
        await db.execute('DROP TABLE IF EXISTS timeline');

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

  static Future<int> insertTimeline(
    Map<String, dynamic> data,
  ) async {

    final db = await database;

    return await db.insert(
      'timeline',
      data,
    );
  }

  // =========================
  // DELETE MONTH
  // =========================

  static Future<int> deleteMonth(
    String month,
    String year,
  ) async {

    final db = await database;

    return await db.delete(
      'timeline',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
  }

  // =========================
  // SEARCH
  // =========================

  static Future<List<Map<String, dynamic>>> searchPeople(
    String query,
  ) async {

    final db = await database;

    return await db.query(

      'timeline',

      where:
          'number LIKE ? OR name LIKE ?',

      whereArgs: [
        '%$query%',
        '%$query%',
      ],

      orderBy: 'name ASC',
    );
  }

  // =========================
  // DASHBOARD STATUS
  // =========================

  static Future<List<Map<String, dynamic>>>
      getStatusStats() async {

    final db = await database;

    return await db.rawQuery('''

      SELECT
        TRIM(status) as status,
        COUNT(*) as count

      FROM timeline

      WHERE
        status IS NOT NULL
        AND status != ''

      GROUP BY TRIM(status)

      ORDER BY count DESC

    ''');
  }
}
