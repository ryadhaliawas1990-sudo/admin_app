import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../db/db_helper.dart';

class ExcelExport {

  static Future<File> exportFiltered({
    String? status,
    String? unit,
    String? rank,
    bool openAfter = true,
    bool shareAfter = false,
  }) async {

    final db = await DBHelper.database;

    String where = '1=1';
    List args = [];

    if (status != null) {
      where += ' AND status = ?';
      args.add(status);
    }

    if (unit != null) {
      where += ' AND unit = ?';
      args.add(unit);
    }

    if (rank != null) {
      where += ' AND rank = ?';
      args.add(rank);
    }

    final data = await db.query(
      'timeline',
      where: where,
      whereArgs: args,
    );

    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    // 🟢 headers
    sheet.appendRow([
      TextCellValue('الرقم'),
      TextCellValue('الرتبة'),
      TextCellValue('الاسم'),
      TextCellValue('الوحدة'),
      TextCellValue('الحالة'),
      TextCellValue('الشهر'),
      TextCellValue('السنة'),
    ]);

    for (var row in data) {
      sheet.appendRow([
        TextCellValue(row['number'].toString()),
        TextCellValue(row['rank'].toString()),
        TextCellValue(row['name'].toString()),
        TextCellValue(row['unit'].toString()),
        TextCellValue(row['status'].toString()),
        TextCellValue(row['month'].toString()),
        TextCellValue(row['year'].toString()),
      ]);
    }

    // 🟢 اسم ملف تلقائي حسب الفلتر
    String fileName = "report";

    if (status != null) fileName += "_$status";
    if (unit != null) fileName += "_$unit";
    if (rank != null) fileName += "_$rank";

    fileName += "_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }

    // 🟢 فتح الملف مباشرة
    if (openAfter) {
      await OpenFile.open(file.path);
    }

    // 🟢 مشاركة الملف
    if (shareAfter) {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'تقرير Excel',
      );
    }

    return file;
  }
}
