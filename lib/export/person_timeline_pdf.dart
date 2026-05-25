import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';

import '../db/db_helper.dart';

class PersonTimelinePdf {

  static Future<String?> generate({
    required String number,
    String headerText = "تقرير المباينة",
  }) async {

    final data = await DBHelper.getPersonTimeline(number);

    if (data.isEmpty) {
      return null;
    }

    final name = data.first['name']?.toString() ?? '';
    final rank = data.first['rank']?.toString() ?? '';

    final excel = Excel.createExcel();
    final sheet = excel['Person Report'];

    // =====================
    // Header Info
    // =====================
    sheet.appendRow([
      TextCellValue(headerText),
    ]);

    sheet.appendRow([
      TextCellValue("الاسم"),
      TextCellValue(name),
    ]);

    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue(number),
    ]);

    sheet.appendRow([
      TextCellValue("الرتبة"),
      TextCellValue(rank),
    ]);

    sheet.appendRow([]);

    // =====================
    // Table Header
    // =====================
    sheet.appendRow([
      TextCellValue("الشهر"),
      TextCellValue("السنة"),
      TextCellValue("الحالة"),
      TextCellValue("الوحدة"),
    ]);

    // =====================
    // Data Rows
    // =====================
    for (var e in data) {
      sheet.appendRow([
        TextCellValue(e['month']?.toString() ?? ''),
        TextCellValue(e['year']?.toString() ?? ''),
        TextCellValue(e['status']?.toString() ?? ''),
        TextCellValue(e['unit']?.toString() ?? ''),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/person_$number.xlsx");

    final bytes = excel.encode();

    if (bytes == null) {
      throw Exception("فشل إنشاء ملف Excel");
    }

    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);

    return file.path;
  }
}
