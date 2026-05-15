import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../../db/db_helper.dart';

class ExcelImport {

  static Future<void> importTimeline() async {

    // اختيار ملف Excel
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    // إلغاء
    if (result == null) {
      return;
    }

    // مسار الملف
    final path = result.files.single.path;

    if (path == null) {
      return;
    }

    // قراءة الملف
    final file = File(path);

    final bytes = file.readAsBytesSync();

    // فتح Excel
    final excel = Excel.decodeBytes(bytes);

    // أول Sheet
    final sheet = excel.tables.values.first;

    // لا يوجد بيانات
    if (sheet == null) {
      return;
    }

    // المرور على الصفوف
    // الصف الأول عناوين
    for (int i = 1; i < sheet.rows.length; i++) {

      final row = sheet.rows[i];

      // حماية من الصفوف الناقصة
      if (row.length < 7) {
        continue;
      }

      final number = row[0]?.value.toString() ?? '';
      final name = row[1]?.value.toString() ?? '';
      final rank = row[2]?.value.toString() ?? '';
      final unit = row[3]?.value.toString() ?? '';
      final status = row[4]?.value.toString() ?? '';
      final month = row[5]?.value.toString() ?? '';
      final year = row[6]?.value.toString() ?? '';

      // تجاهل السطر الفارغ
      if (number.isEmpty && name.isEmpty) {
        continue;
      }

      // إدخال قاعدة البيانات
      await DBHelper.insertTimeline({
        'number': number,
        'name': name,
        'rank': rank,
        'unit': unit,
        'status': status,
        'month': month,
        'year': year,
      });
    }
  }
}
