import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/excel_reader.dart';
import '../../core/name_matcher.dart';

class CompareTwoFiles {

  static Future<String?> run() async {

    // =========================
    // اختيار الملف القديم
    // =========================
    final oldFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (oldFile == null) return null;

    // =========================
    // اختيار الملف الجديد
    // =========================
    final newFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (newFile == null) return null;

    final oldExcel = Excel.decodeBytes(
      File(oldFile.files.single.path!).readAsBytesSync(),
    );

    final newExcel = Excel.decodeBytes(
      File(newFile.files.single.path!).readAsBytesSync(),
    );

    final oldSheet = oldExcel.tables.values.first;
    final newSheet = newExcel.tables.values.first;

    final oldData = ExcelReader.readData(oldSheet);
    final newData = ExcelReader.readData(newSheet);

    List<Map<String, dynamic>> usedNew = [];

    List<Map<String, dynamic>> changed = [];
    List<Map<String, dynamic>> added = [];
    List<Map<String, dynamic>> missing = [];

    // =========================
    // مقارنة الملف القديم
    // =========================
    for (var old in oldData) {

      String oldNumber = (old['الرقم'] ?? '').toString();
      String oldName = (old['الاسم'] ?? '').toString();
      String oldStatus = (old['الحالة'] ?? '').toString();

      Map<String, dynamic>? found;

      // 🔹 مطابقة بالرقم
      for (var n in newData) {

        if ((n['الرقم'] ?? '').toString() == oldNumber &&
            oldNumber.isNotEmpty) {

          found = n;
          usedNew.add(n);
          break;
        }
      }

      // 🔹 مطابقة بالاسم
      if (found == null) {

        for (var n in newData) {

          if (!usedNew.contains(n) &&
              NameMatcher.isSimilar(
                oldName,
                (n['الاسم'] ?? '').toString(),
              )) {

            found = n;
            usedNew.add(n);
            break;
          }
        }
      }

      // =========================
      // تحليل النتيجة
      // =========================
      if (found != null) {

        String newStatus = (found['الحالة'] ?? '').toString();

        if (oldStatus != newStatus) {

          changed.add({
            'number': oldNumber,
            'name': oldName,
            'old': oldStatus,
            'new': newStatus,
          });
        }

      } else {

        missing.add({
          'number': oldNumber,
          'name': oldName,
        });
      }
    }

    // =========================
    // العناصر الجديدة
    // =========================
    for (var n in newData) {

      if (!usedNew.contains(n)) {

        added.add({
          'number': (n['الرقم'] ?? '').toString(),
          'name': (n['الاسم'] ?? '').toString(),
        });
      }
    }

    // =========================
    // إنشاء ملف النتيجة
    // =========================
    final excel = Excel.createExcel();
    final sheet = excel['Result'];

    sheet.appendRow([
      TextCellValue('الرقم'),
      TextCellValue('الاسم'),
      TextCellValue('الحالة القديمة'),
      TextCellValue('الحالة الجديدة'),
      TextCellValue('النتيجة'),
    ]);

    for (var c in changed) {

      sheet.appendRow([
        TextCellValue(c['number'] ?? ''),
        TextCellValue(c['name'] ?? ''),
        TextCellValue(c['old'] ?? ''),
        TextCellValue(c['new'] ?? ''),
        TextCellValue('تغير'),
      ]);
    }

    for (var m in missing) {

      sheet.appendRow([
        TextCellValue(m['number'] ?? ''),
        TextCellValue(m['name'] ?? ''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('مفقود'),
      ]);
    }

    for (var a in added) {

      sheet.appendRow([
        TextCellValue(a['number'] ?? ''),
        TextCellValue(a['name'] ?? ''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('جديد'),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      '${dir.path}/comparison_result.xlsx',
    );

    final bytes = excel.encode()!;

    await file.writeAsBytes(bytes);

    return file.path;
  }
}
