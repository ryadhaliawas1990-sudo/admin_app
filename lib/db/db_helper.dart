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

        await db.execute('CREATE INDEX idx_number ON timeline(number)');
        await db.execute('CREATE INDEX idx_name ON timeline(name)');
        await db.execute('CREATE INDEX idx_month_year ON timeline(month, year)');
      },

      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 2) {

          await db.execute('''
            CREATE TABLE IF NOT EXISTS imported_months (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              month TEXT,
              year TEXT,
              imported_at TEXT
            )
          ''');

          await db.execute('CREATE INDEX IF NOT EXISTS idx_number ON timeline(number)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_name ON timeline(name)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_month_year ON timeline(month, year)');
        }
      },
    );
  }

  // =========================
  // INSERT
  // =========================

  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('timeline', data);
  }

  // =========================
  // GET ALL (مطلوب في HR)
  // =========================

  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;

    return db.query(
      'timeline',
      orderBy: 'id DESC',
    );
  }

  // =========================
  // PAGINATION (تسريع العرض)
  // =========================

  static Future<List<Map<String, dynamic>>> getTimelinePaged({
    required int limit,
    required int offset,
  }) async {

    final db = await database;

    return db.query(
      'timeline',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  // =========================
  // GET PERSON TIMELINE
  // =========================

  static Future<List<Map<String, dynamic>>> getPersonTimeline(String number) async {

    final db = await database;

    return db.query(
      'timeline',
      where: 'number = ?',
      whereArgs: [number],
      orderBy: 'year ASC, month ASC',
    );
  }

  // =========================
  // ADVANCED SEARCH
  // =========================

  static Future<List<Map<String, dynamic>>> advancedSearch({
    String? query,
    String? month,
    String? year,
    String? status,
    String? unit,
  }) async {

    final db = await database;

    final conditions = <String>[];
    final args = <String>[];

    if (query != null && query.isNotEmpty) {
      conditions.add('''
        (number LIKE ? OR
         name LIKE ? OR
         rank LIKE ? OR
         unit LIKE ? OR
         status LIKE ?)
      ''');

      args.addAll(List.filled(5, '%$query%'));
    }

    if (month != null && month.isNotEmpty) {
      conditions.add('month = ?');
      args.add(month);
    }

    if (year != null && year.isNotEmpty) {
      conditions.add('year = ?');
      args.add(year);
    }

    if (status != null && status.isNotEmpty) {
      conditions.add('status = ?');
      args.add(status);
    }

    if (unit != null && unit.isNotEmpty) {
      conditions.add('unit = ?');
      args.add(unit);
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    return db.query(
      'timeline',
      where: where,
      whereArgs: args,
      orderBy: 'year DESC, month DESC',
    );
  }

  // =========================
  // MONTH CONTROL
  // =========================

  static Future<bool> isMonthImported(String month, String year) async {
    final db = await database;

    final result = await db.query(
      'imported_months',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    return result.isNotEmpty;
  }

  static Future<void> markMonthImported(String month, String year) async {
    final db = await database;

    await db.insert('imported_months', {
      'month': month,
      'year': year,
      'imported_at': DateTime.now().toIso8601String(),
    });
  }

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
}
