import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

import '../db/db_helper.dart';

class ExcelImport {

  /// 📥 اختيار ملف من الجهاز + استيراد مباشر
  static Future<void> pickAndImport(String month) async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    Uint8List bytes;

    if (result.files.single.bytes != null) {
      bytes = result.files.single.bytes!;
    } else {
      bytes = await File(result.files.single.path!).readAsBytes();
    }

    await _importExcel(bytes, month);
  }

  /// 📊 قراءة Excel وحفظه في قاعدة البيانات
  static Future<void> _importExcel(Uint8List bytes, String month) async {

    final excel = Excel.decodeBytes(bytes);

    for (var sheetName in excel.tables.keys) {

      final sheet = excel.tables[sheetName];
      if (sheet == null) continue;

      final rows = sheet.rows;

      for (var row in rows.skip(1)) {

        await DBHelper.insertPerson({
          "name": row.isNotEmpty ? row[0]?.value?.toString() ?? "" : "",
          "number": row.length > 1 ? row[1]?.value?.toString() ?? "" : "",
          "rank": row.length > 2 ? row[2]?.value?.toString() ?? "" : "",
          "unit": row.length > 3 ? row[3]?.value?.toString() ?? "" : "",
          "status": row.length > 4 ? row[4]?.value?.toString() ?? "" : "",
          "month": month,
        });
      }
    }
  }
}
