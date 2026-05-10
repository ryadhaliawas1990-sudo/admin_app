import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExport {

  static Future<String> exportToExcel(
    List<Map<String, dynamic>> people,
  ) async {

    var excel = Excel.createExcel();

    Sheet sheet = excel['الأفراد'];

    // العناوين
    sheet.appendRow([
      TextCellValue('الاسم'),
      TextCellValue('الرقم'),
      TextCellValue('الرتبة'),
      TextCellValue('الوحدة'),
      TextCellValue('الحالة'),
    ]);

    // البيانات
    for (var p in people) {
      sheet.appendRow([
        TextCellValue(p['name'] ?? ''),
        TextCellValue(p['number'] ?? ''),
        TextCellValue(p['rank'] ?? ''),
        TextCellValue(p['unit'] ?? ''),
        TextCellValue(p['status'] ?? ''),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();

    String path = "${dir.path}/people.xlsx";

    File file = File(path);

    await file.writeAsBytes(
      excel.encode()!,
    );

    return path;
  }
}
