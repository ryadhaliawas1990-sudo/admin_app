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

    if (result == null) {
      return;
    }

    final path = result.files.single.path;

    if (path == null) {
      return;
    }

    final file = File(path);

    final bytes = file.readAsBytesSync();

    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables.values.first;

    if (sheet == null) {
      return;
    }

    // الصف الأول عناوين
    for (int i = 1; i < sheet.rows.length; i++) {

      final row = sheet.rows[i];

      if (row.length < 5) {
        continue;
      }

      final number =
          row[0]?.value.toString() ?? '';

      final rank =
          row[1]?.value.toString() ?? '';

      final name =
          row[2]?.value.toString() ?? '';

      final unit =
          row[3]?.value.toString() ?? '';

      final status =
          row[4]?.value.toString() ?? '';

      if (number.isEmpty && name.isEmpty) {
        continue;
      }

      await DBHelper.insertTimeline({

        'number': number,
        'rank': rank,
        'name': name,
        'unit': unit,
        'status': status,
        'month': month,
        'year': year,
      });
    }
  }
}
