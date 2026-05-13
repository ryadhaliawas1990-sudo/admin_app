import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelImportService {

  static Future<List<Map<String, dynamic>>> pickAndReadExcel() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    // ❌ لا يوجد ملف
    if (result == null || result.files.isEmpty) {
      return [];
    }

    final file = result.files.first;

    // ❌ حماية من null path
    if (file.path == null) {
      return [];
    }

    final bytes = File(file.path!).readAsBytesSync();

    final excel = Excel.decodeBytes(bytes);

    final List<Map<String, dynamic>> data = [];

    // 📊 المرور على كل الشيتات داخل الملف
    for (var tableName in excel.tables.keys) {

      final sheet = excel.tables[tableName];

      if (sheet == null) continue;

      // ⛔ تجاهل الهيدر (السطر الأول)
      for (int i = 1; i < sheet.rows.length; i++) {

        final row = sheet.rows[i];

        if (row.isEmpty) continue;

        final number = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? "" : "";
        final name = row.length > 1 ? row[1]?.value?.toString().trim() ?? "" : "";
        final status = row.length > 2 ? row[2]?.value?.toString().trim() ?? "" : "";

        // ❌ تجاهل الصفوف الفارغة
        if (number.isEmpty && name.isEmpty) {
          continue;
        }

        data.add({
          "number": number,
          "name": name,
          "status": status,
        });
      }
    }

    return data;
  }
}
