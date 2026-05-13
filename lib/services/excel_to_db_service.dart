import '../db/db_helper.dart';

class ExcelToDbService {

  static Future<void> import(List<Map<String, dynamic>> data, String month) async {

    for (var row in data) {

      final number = row["number"]?.toString() ?? "";

      if (number.isEmpty) continue;

      await DBHelper.insertPerson({
        "name": row["name"] ?? "",
        "number": number,
        "rank": row["rank"] ?? "",
        "unit": row["unit"] ?? "",
        "status": row["status"] ?? "",
        "month": month,
      });
    }
  }
}
