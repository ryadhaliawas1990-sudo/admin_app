import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  static Database? _db;

  // =========================
  // 🧠 فتح قاعدة البيانات
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
  // 👤 جلب كل الأشخاص
  // =========================
  static Future<List<Map<String, dynamic>>> getPeople() async {
    final db = await database;
    return await db.query('people');
  }

  // =========================
  // 📅 جلب حسب الشهر (المباينة)
  // =========================
  static Future<List<Map<String, dynamic>>> getByMonth(String month) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'month = ?',
      whereArgs: [month],
    );
  }

  // =========================
  // ➕ إدخال شخص
  // =========================
  static Future<int> insertPerson(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('people', data);
  }

  // =========================
  // ✏️ تحديث شخص
  // =========================
  static Future<int> updatePerson(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'people',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // ❌ حذف شخص
  // =========================
  static Future<int> deletePerson(int id) async {
    final db = await database;

    return await db.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // 🔍 بحث
  // =========================
  static Future<List<Map<String, dynamic>>> searchPeople(String query) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'name LIKE ? OR number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // =========================
  // 📊 جلب التقارير (اختياري للتوسع لاحقاً)
  // =========================
  static Future<List<Map<String, dynamic>>> getReports() async {
    final db = await database;
    return await db.query('people'); // مؤقتاً نفس الجدول
  }

  // =========================
  // 🧾 سجل العمليات (اختياري)
  // =========================
  static Future<List<Map<String, dynamic>>> getLogs() async {
    return [];
  }
}
