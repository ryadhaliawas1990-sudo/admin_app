import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../../db/db_helper.dart';

class ExcelImport {

  static Future<void> importTimeline({
    required String month,
    required String year,
  }) async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables.values.first;
    if (sheet == null) return;

    final db = await DBHelper.database;

    // 🔥 بداية Transaction (أهم تحسين أداء)
    await db.transaction((txn) async {

      final batch = txn.batch();

      for (int i = 1; i < sheet.rows.length; i++) {

        final row = sheet.rows[i];

        if (row.length < 6) continue;

        final number = row[1]?.value.toString().trim() ?? '';
        final rank   = row[2]?.value.toString().trim() ?? '';
        final name   = row[3]?.value.toString().trim() ?? '';
        final unit   = row[4]?.value.toString().trim() ?? '';
        final status = row[5]?.value.toString().trim() ?? '';

        if (number.isEmpty && name.isEmpty) continue;

        batch.insert('timeline', {
          'number': number,
          'rank': rank,
          'name': name,
          'unit': unit,
          'status': status,
          'month': month,
          'year': year,
        });
      }

      // 🚀 تنفيذ كل الإدخالات دفعة واحدة
      await batch.commit(noResult: true);
    });
  }
}
