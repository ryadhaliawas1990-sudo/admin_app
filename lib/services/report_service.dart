import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportService {

  static Future<void> generateHrReport({
    required List<Map<String, dynamic>> records,
    required String selectedYear,
  }) async {

    final excel = Excel.createExcel();
    final sheet = excel['HR Report'];

    // =========================
    // تجميع البيانات
    // =========================
    Map<String, Map<String, dynamic>> grouped = {};
    List<String> allMonths = [];

    for (final row in records) {
      final number = (row['number'] ?? '').toString();
      final month = "${row['month']}/${row['year']}";

      if (!allMonths.contains(month)) {
        allMonths.add(month);
      }

      if (!grouped.containsKey(number)) {
        grouped[number] = {
          "number": row['number'],
          "rank": row['rank'],
          "name": row['name'],
          "unit": row['unit'],
          "months": {},
        };
      }

      grouped[number]!["months"][month] = row['status'];
    }

    // =========================
    // HEADER
    // =========================
    List<CellValue> header = [
      TextCellValue("الرقم العسكري"),
      TextCellValue("الرتبة"),
      TextCellValue("الاسم"),
      TextCellValue("الوحدة"),
    ];

    for (final m in allMonths) {
      header.add(TextCellValue(m));
    }

    sheet.appendRow(header);

    // =========================
    // DATA
    // =========================
    for (final person in grouped.values) {
      List<CellValue> row = [
        TextCellValue((person['number'] ?? '').toString()),
        TextCellValue((person['rank'] ?? '').toString()),
        TextCellValue((person['name'] ?? '').toString()),
        TextCellValue((person['unit'] ?? '').toString()),
      ];

      for (final m in allMonths) {
        row.add(
          TextCellValue((person['months'][m] ?? '').toString()),
        );
      }

      sheet.appendRow(row);
    }

    // =========================
    // حفظ الملف
    // =========================
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/hr_report.xlsx");

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception("فشل إنشاء Excel");
    }

    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}
