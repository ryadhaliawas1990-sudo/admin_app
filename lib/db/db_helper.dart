import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await openDatabase(join(await getDatabasesPath(), 'admin_app.db'), version: 1);
    return _database!;
  }

  // الدوال المفقودة والتي يطلبها التطبيق:
  static Future<List<Map<String, dynamic>>> getMonthlyRecords(String m, String y) async => (await database).query('timeline', where: 'month = ? AND year = ?', whereArgs: [m, y]);
  static Future<List<Map<String, dynamic>>> getPersonTimeline(int id) async => (await database).query('timeline', where: 'id = ?', whereArgs: [id]);
  static Future<void> insertTimeline(Map<String, dynamic> d) async => (await database).insert('timeline', d);
  static Future<List<Map<String, dynamic>>> getReports() async => (await database).query('reports');
  static Future<List<Map<String, dynamic>>> getLogs() async => (await database).query('logs');
  static Future<List<String>> getImportedMonths() async => []; 
  static Future<List<Map<String, dynamic>>> getPeople() async => (await database).query('people');
  static Future<List<Map<String, dynamic>>> getTimelinePaged({required int limit, required int offset}) async => (await database).query('timeline', limit: limit, offset: offset);
  static Future<List<Map<String, dynamic>>> advancedSearch({required String query, String? month, String? status}) async => (await database).query('timeline');

  // الدوال الأصلية:
  static Future<void> deleteMonthData(String m, String y) async => (await database).delete('timeline', where: 'month = ? AND year = ?', whereArgs: [m, y]);
  static Future<void> markMonthImported(String m, String y) async => (await database).update('timeline', {'status': 'imported'}, where: 'month = ? AND year = ?', whereArgs: [m, y]);
  static Future<List<Map<String, dynamic>>> getByMonth(String m, String y) async => (await database).query('timeline', where: 'month = ? AND year = ?', whereArgs: [m, y]);
  static Future<void> updatePersonStatus(int id, String s) async => (await database).update('timeline', {'status': s}, where: 'id = ?', whereArgs: [id]);
}
