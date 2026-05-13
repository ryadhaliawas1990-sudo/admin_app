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
    final path = join(await getDatabasesPath(), 'admin_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE people (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            number TEXT,
            rank TEXT,
            unit TEXT,
            status TEXT,
            month TEXT
          )
        ''');
      },
    );
  }

  // =========================
  // ➕ إدخال
  // =========================
  static Future<int> insertPerson(
    Map<String, dynamic> data,
  ) async {
    final db = await database;

    return await db.insert(
      'people',
      data,
    );
  }

  // =========================
  // 🔄 إدخال أو تحديث
  // =========================
  static Future<void> insertOrUpdate(
    Map<String, dynamic> data,
  ) async {
    final db = await database;

    await db.insert(
      'people',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // =========================
  // ✏️ تحديث
  // =========================
  static Future<int> updatePerson(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;

    return await db.update(
      'people',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // 👤 جلب كل البيانات
  // =========================
  static Future<List<Map<String, dynamic>>> getPeople() async {
    final db = await database;
    return await db.query('people');
  }

  // =========================
  // 📅 جلب حسب الشهر
  // =========================
  static Future<List<Map<String, dynamic>>> getByMonth(
    String month,
  ) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'month = ?',
      whereArgs: [month],
    );
  }

  // =========================
  // 📊 تقارير
  // =========================
  static Future<List<Map<String, dynamic>>> getReports() async {
    final db = await database;
    return await db.query('people');
  }

  // =========================
  // 🔍 بحث
  // =========================
  static Future<List<Map<String, dynamic>>> searchPeople(
    String query,
  ) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'name LIKE ? OR number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // =========================
  // ❌ حذف
  // =========================
  static Future<int> deletePerson(int id) async {
    final db = await database;

    return await db.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
