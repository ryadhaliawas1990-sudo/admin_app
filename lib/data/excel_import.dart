import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../db/db_helper.dart';

class ExcelImport {

  static Future<void> pickAndImport(
    String month,
  ) async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) {
      return;
    }

    final file = File(
      result.files.single.path!,
    );

    final bytes = file.readAsBytesSync();

    final excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {

      final sheet = excel.tables[table];

      if (sheet == null) {
        continue;
      }

      // يبدأ من السطر الثاني
      for (int i = 1; i < sheet.rows.length; i++) {

        final row = sheet.rows[i];

        // ترتيب أعمدتك الحقيقي

        final number =
            row[1]?.value.toString() ?? '';

        final rank =
            row[2]?.value.toString() ?? '';

        final name =
            row[3]?.value.toString() ?? '';

        final unit =
            row[4]?.value.toString() ?? '';

        final status =
            row[5]?.value.toString() ?? '';

        // تجاهل الصف الفارغ
        if (number.trim().isEmpty) {
          continue;
        }

        // حفظ الشخص
        await DBHelper.insertPerson({

          "name": name,

          "number": number,

          "rank": rank,

          "unit": unit,
        });

        // حفظ الحالة الشهرية
        await DBHelper.insertMonthlyRecord({

          "number": number,

          "month": month,

          "status": status,
        });
      }
    }
  }
}
