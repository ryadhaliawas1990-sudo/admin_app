import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ComparisonExcel {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> data,
  }) async {

    final excel = Excel.createExcel();
    final sheet = excel['Mubayana'];

    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الاسم"),
      TextCellValue("الرتبة"),
      ...months.map((m) => TextCellValue(m)),
      TextCellValue("النسبة"),
    ]);

    for (var p in data) {

      final monthsMap = p["months"] as Map<String, bool>;

      int total = monthsMap.length;
      int present = monthsMap.values.where((v) => v).length;

      double percent = total == 0 ? 0 : present / total;

      sheet.appendRow([
        TextCellValue(p["number"].toString()),
        TextCellValue(p["name"].toString()),
        TextCellValue(p["rank"].toString()),

        ...months.map((m) =>
            TextCellValue((monthsMap[m] ?? false) ? "✔" : "✖")),

        TextCellValue("${(percent * 100).toStringAsFixed(0)}%"),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/comparison.xlsx",
    );

    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }
}
