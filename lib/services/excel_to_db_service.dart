import '../db/db_helper.dart';

class ExcelToDbService {
  static Future<void> import(List<Map<String, dynamic>> data, String month, String year) async {
    for (var row in data) {
      final number = row["number"]?.toString() ?? "";
      if (number.isEmpty) continue;

      // تعديل الدالة والأعمدة لتطابق الهيكل الحقيقي لقاعدة البيانات
      await DBHelper.insertTimeline({
        "number": number,
        "name": row["name"] ?? "",
        "rank": row["rank"] ?? "",
        "unit": row["unit"] ?? "",
        "status": row["status"] ?? "",
        "month": month,
        "year": year,
      });
    }
  }
}
