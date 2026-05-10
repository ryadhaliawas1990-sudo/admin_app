import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

import '../db/db_helper.dart';

class ExcelImport {

  /// 📥 اختيار ملف من الجهاز
  static Future<void> pickAndImport(String month) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    Uint8List bytes = result.files.single.bytes ??
        await File(result.files.single.path!).readAsBytes();

    await _importExcel(bytes, month);
  }

  /// 📊 قراءة Excel وحفظه في قاعدة البيانات
  static Future<void> _importExcel(Uint8List bytes, String month) async {
    var excel = Excel.decodeBytes(bytes);

    for (var sheet in excel.tables.keys) {
      var rows = excel.tables[sheet]!.rows;

      for (var row in rows.skip(1)) {
        await DBHelper.insertPerson({
          "name": row[0]?.value?.toString() ?? "",
          "number": row[1]?.value?.toString() ?? "",
          "rank": row[2]?.value?.toString() ?? "",
          "unit": row[3]?.value?.toString() ?? "",
          "status": row[4]?.value?.toString() ?? "",
          "month": month,
        });
      }
    }
  }
}
