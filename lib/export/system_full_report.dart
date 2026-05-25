import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class SystemFullReport {

  static Future<String> export({
    required List<Map<String, dynamic>> data,
    required String title,
  }) async {

    final excel = Excel.createExcel();
    final sheet = excel['System Report'];

    // =========================
    // Title
    // =========================
    sheet.appendRow([
      TextCellValue(title),
    ]);

    sheet.appendRow([]);

    // =========================
    // Headers
    // =========================
    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الاسم"),
      TextCellValue("الرتبة"),
      TextCellValue("الوحدة"),
      TextCellValue("الحالة"),
    ]);

    // =========================
    // Data rows
    // =========================
    for (final e in data) {
      sheet.appendRow([
        TextCellValue((e["number"] ?? "").toString()),
        TextCellValue((e["name"] ?? "").toString()),
        TextCellValue((e["rank"] ?? "").toString()),
        TextCellValue((e["unit"] ?? "").toString()),
        TextCellValue((e["status"] ?? "").toString()),
      ]);
    }

    // =========================
    // Save file
    // =========================
    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/system_report_${DateTime.now().millisecondsSinceEpoch}.xlsx",
    );

    final bytes = excel.encode();

    if (bytes == null) {
      throw Exception("فشل إنشاء ملف Excel");
    }

    await file.writeAsBytes(bytes);

    return file.path;
  }
}
