import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../db/db_helper.dart';

class ExportService {

  // =========================
  // Excel Export (UNCHANGED)
  // =========================
  static Future<String?> exportExcel({
    String? year,
    String? status,
    String? unit,
  }) async {

    final db = await DBHelper.database;

    String query = "SELECT * FROM timeline WHERE 1=1";
    List args = [];

    if (year != null) {
      query += " AND year = ?";
      args.add(year);
    }

    if (status != null) {
      query += " AND status = ?";
      args.add(status);
    }

    if (unit != null) {
      query += " AND unit = ?";
      args.add(unit);
    }

    final data = await db.rawQuery(query, args);

    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الاسم"),
      TextCellValue("الرتبة"),
      TextCellValue("الوحدة"),
      TextCellValue("الحالة"),
      TextCellValue("الشهر"),
      TextCellValue("السنة"),
    ]);

    for (var e in data) {
      sheet.appendRow([
        TextCellValue((e['number'] ?? '').toString()),
        TextCellValue((e['name'] ?? '').toString()),
        TextCellValue((e['rank'] ?? '').toString()),
        TextCellValue((e['unit'] ?? '').toString()),
        TextCellValue((e['status'] ?? '').toString()),
        TextCellValue((e['month'] ?? '').toString()),
        TextCellValue((e['year'] ?? '').toString()),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/report.xlsx");

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception("فشل إنشاء ملف Excel");
    }

    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);

    return file.path;
  }

  // =========================
  // PDF Export (DISABLED بالكامل)
  // =========================
  static Future<String?> exportPdf({
    String title = "تقرير رسمي",
    String? year,
    String? status,
    String? unit,
  }) async {

    // 🚫 تم تعطيل PDF نهائياً لمنع مشاكل المربعات
    throw Exception(
      "PDF Export is disabled. Use ExcelExport instead."
    );
  }
}
