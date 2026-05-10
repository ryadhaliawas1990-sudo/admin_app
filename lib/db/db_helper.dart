import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'admin.db');

    return await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE people ADD COLUMN month TEXT");
        }
      },
      onCreate: (db, version) async {
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
      },
    );
  }

  // ➕ إضافة شخص
  static Future<int> insertPerson(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('people', data);
  }

  // 📋 جلب الكل
  static Future<List<Map<String, dynamic>>> getPeople() async {
    final db = await database;
    return await db.query('people', orderBy: 'id DESC');
  }

  // 📅 جلب حسب الشهر (أساسي للمقارنة)
  static Future<List<Map<String, dynamic>>> getByMonth(String month) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'month = ?',
      whereArgs: [month],
      orderBy: 'id DESC',
    );
  }

  // 🔍 بحث عام
  static Future<List<Map<String, dynamic>>> searchPeople(String query) async {
    final db = await database;

    return await db.query(
      'people',
      where: 'name LIKE ? OR number LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // ✏️ تحديث شخص (مهم للتعديل)
  static Future<int> updatePerson(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'people',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ❌ حذف شخص
  static Future<void> deletePerson(int id) async {
    final db = await database;

    await db.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 📊 (مهم للمقارنة) جلب كل الأشهر المختلفة
  static Future<List<Map<String, dynamic>>> getMonths() async {
    final db = await database;

    return await db.rawQuery(
      'SELECT DISTINCT month FROM people ORDER BY month DESC',
    );
  }
}
