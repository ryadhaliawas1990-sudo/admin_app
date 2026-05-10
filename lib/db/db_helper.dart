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
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE people(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            number TEXT,
            rank TEXT,
            unit TEXT,
            status TEXT
          )
        ''');

      },
    );
  }

  static Future<int> insertPerson(Map<String, dynamic> data) async {
    final db = await database;

    return await db.insert('people', data);
  }

  static Future<List<Map<String, dynamic>>> getPeople() async {
    final db = await database;

    return await db.query('people');
  }
}
