import '../db/db_helper.dart';

class ExcelToDbService {
  static String _normalize(String text) {
    return text.replaceAll('ه', 'ة').trim();
  }

  static Future<void> import(
    List<Map<String, dynamic>> data,
    String month,
    String year,
  ) async {
    for (var row in data) {
      final number = row["number"]?.toString() ?? row["الرقم العسكري"]?.toString() ?? "";

      if (number.isEmpty) continue;

      await DBHelper.insertTimeline({
        "number": number,
        "name": row["name"] ?? row["الاسم"] ?? "",
        "rank": row["rank"] ?? row["الرتبة"] ?? "",
        "unit": _normalize(row["unit"] ?? row["الوحدة"] ?? row["الوحده"] ?? ""),
        "status": _normalize(row["status"] ?? row["الحالة"] ?? row["الحاله"] ?? ""),
        "month": month,
        "year": year,
      });
    }
  }
}
