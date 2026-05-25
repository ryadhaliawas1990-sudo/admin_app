import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';

import '../db/db_helper.dart';

class BatchTimelinePdf {

  static Future<String?> generate({
    required List<String> numbers,
    String headerText = "تقرير مباينة جماعي",
  }) async {

    final excel = Excel.createExcel();
    final sheet = excel['Batch Report'];

    // Header
    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الاسم"),
      TextCellValue("الرتبة"),
      TextCellValue("الشهر"),
      TextCellValue("السنة"),
      TextCellValue("الحالة"),
      TextCellValue("الوحدة"),
    ]);

    for (String number in numbers) {

      final data = await DBHelper.getPersonTimeline(number);

      if (data.isEmpty) continue;

      final name = data.first['name'] ?? '';
      final rank = data.first['rank'] ?? '';

      for (var e in data) {
        sheet.appendRow([
          TextCellValue(number),
          TextCellValue(name.toString()),
          TextCellValue(rank.toString()),
          TextCellValue(e['month'] ?? ''),
          TextCellValue(e['year'] ?? ''),
          TextCellValue(e['status'] ?? ''),
          TextCellValue(e['unit'] ?? ''),
        ]);
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/batch_report.xlsx");

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception("فشل إنشاء ملف Excel");
    }

    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);

    return file.path;
  }
}
