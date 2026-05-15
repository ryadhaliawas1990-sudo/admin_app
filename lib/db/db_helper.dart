import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {

  static Database? _db;

  // فتح قاعدة البيانات
  static Future<Database> get database async {

    if (_db != null) {
      return _db!;
    }

    _db = await initDB();

    return _db!;
  }

  // إنشاء قاعدة البيانات
  static Future<Database> initDB() async {

    final path = join(
      await getDatabasesPath(),
      'admin_app.db',
    );

    return await openDatabase(
      path,
      version: 2,

      onCreate: (db, version) async {

        // جدول الأشخاص
        await db.execute('''
          CREATE TABLE people (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            number TEXT UNIQUE,
            rank TEXT,
            unit TEXT
          )
        ''');

        // جدول السجل الشهري
        await db.execute('''
          CREATE TABLE monthly_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            number TEXT,
            month TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  // إضافة شخص
  static Future<void> insertPerson(
    Map<String, dynamic> data,
  ) async {

    final db = await database;

    await db.insert(
      'people',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // إضافة سجل شهري
  static Future<void> insertMonthlyRecord(
    Map<String, dynamic> data,
  ) async {

    final db = await database;

    await db.insert(
      'monthly_records',
      data,
    );
  }

  // جلب الأشخاص
  static Future<List<Map<String, dynamic>>> getPeople() async {

    final db = await database;

    return await db.query('people');
  }

  // جلب سجلات شهر محدد
  static Future<List<Map<String, dynamic>>> getMonthlyRecords(
    String month,
  ) async {

    final db = await database;

    return await db.query(
      'monthly_records',
      where: 'month = ?',
      whereArgs: [month],
    );
  }

  // حذف جميع السجلات
  static Future<void> clearAll() async {

    final db = await database;

    await db.delete('people');

    await db.delete('monthly_records');
  }
}
