import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timeline.db');

    return await openDatabase(
      path,
      version: 3, 
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
            await _createTables(db);
        }
        if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                number TEXT,
                month TEXT,
                year TEXT,
                note_text TEXT
              )
            ''');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
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
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        month TEXT,
        year TEXT,
        note_text TEXT
      )
    ''');
  }

  // =========================
  // العمليات على السجلات (Timeline)
  // =========================
  static Future<int> insertTimeline(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('timeline', {
      "number": (data["number"] ?? "").toString(),
      "name": (data["name"] ?? "").toString(),
      "rank": (data["rank"] ?? "").toString(),
      "unit": (data["unit"] ?? "").toString(),
      "status": (data["status"] ?? "").toString(),
      "month": (data["month"] ?? "").toString(),
      "year": (data["year"] ?? "").toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateTimeline(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('timeline', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getPersonTimeline(String number) async {
    final db = await database;
    return await db.query('timeline', where: 'number = ?', whereArgs: [number], orderBy: 'CAST(year AS INTEGER) DESC, CAST(month AS INTEGER) DESC');
  }

  static Future<int> deleteMonth(String month, String year) async {
    final db = await database;
    return await db.delete('timeline', where: 'month = ? AND year = ?', whereArgs: [month, year]);
  }

  static Future<List<Map<String, dynamic>>> getImportedMonths() async {
    final db = await database;
    return await db.rawQuery('SELECT month, year, COUNT(*) as total FROM timeline GROUP BY month, year ORDER BY CAST(year AS INTEGER) DESC, CAST(month AS INTEGER) DESC');
  }

  static Future<List<Map<String, dynamic>>> getAllTimeline() async {
    final db = await database;
    return await db.query('timeline', orderBy: 'CAST(year AS INTEGER) DESC, CAST(month AS INTEGER) DESC');
  }

  static Future<int> deleteTimeline(int id) async {
    final db = await database;
    return await db.delete('timeline', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('timeline');
    await db.delete('notes');
  }

  // =========================
  // العمليات على الملاحظات (Notes)
  // =========================
  static Future<int> addNote(String number, String month, String year, String note) async {
    final db = await database;
    return await db.insert('notes', {
      "number": number, "month": month, "year": year, "note_text": note
    });
  }

  static Future<List<Map<String, dynamic>>> getNotesForPerson(String number) async {
    final db = await database;
    return await db.query('notes', where: 'number = ?', whereArgs: [number]);
  }
}
