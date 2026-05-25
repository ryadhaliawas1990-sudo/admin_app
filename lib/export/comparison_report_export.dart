import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class ComparisonReportExport {

  // =========================
  // 📊 EXCEL EXPORT (FINAL VERSION)
  // =========================
  static Future<String> exportExcel({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    required Map<String, List<Map<String, dynamic>>> dataByMonth,
    required String title,
  }) async {

    final excel = Excel.createExcel();
    final sheet = excel['Comparison Report'];

    // =========================
    // Title
    // =========================
    sheet.appendRow([
      TextCellValue(title),
    ]);

    sheet.appendRow([]);

    // =========================
    // Header
    // =========================
    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الاسم"),
      ...months.map((m) => TextCellValue(m)),
    ]);

    // =========================
    // Data Rows
    // =========================
    for (var p in people) {

      final row = <TextCellValue>[];

      row.add(TextCellValue((p["number"] ?? "").toString()));
      row.add(TextCellValue((p["name"] ?? "").toString()));

      for (var m in months) {

        final monthData = dataByMonth[m] ?? [];

        final exists = monthData.any(
          (e) => e["number"] == p["number"],
        );

        row.add(TextCellValue(exists ? "✔" : "✖"));
      }

      sheet.appendRow(row);
    }

    // =========================
    // Save file
    // =========================
    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/comparison_${DateTime.now().millisecondsSinceEpoch}.xlsx",
    );

    final bytes = excel.encode();

    if (bytes == null) {
      throw Exception("فشل إنشاء ملف Excel");
    }

    await file.writeAsBytes(bytes);

    return file.path;
  }
}
