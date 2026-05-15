import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/excel_reader.dart';
import '../../core/name_matcher.dart';

class CompareTwoFiles {

  static Future<String?> run() async {

    final oldFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (oldFile == null) return null;

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

    // ==============================
    // 1️⃣ القديم
    // ==============================
    for (var old in oldData) {

      String oldNumber = (old['الرقم'] ?? '').toString();
      String oldName = (old['الاسم'] ?? '').toString();
      String oldStatus = (old['الحالة'] ?? '').toString();

      Map<String, dynamic>? found;

      // 🔹 رقم
      for (var n in newData) {

        if ((n['الرقم'] ?? '').toString() == oldNumber &&
            oldNumber.isNotEmpty) {

          found = n;
          usedNew.add(n);
          break;
        }
      }

      // 🔹 اسم
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

      // ==============================
      // النتيجة
      // ==============================
      if (found != null) {

        final newStatus = (found['الحالة'] ?? '').toString();

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

    // ==============================
    // 2️⃣ الجديد
    // ==============================
    for (var n in newData) {

      if (!usedNew.contains(n)) {

        added.add({
          'number': (n['الرقم'] ?? '').toString(),
          'name': (n['الاسم'] ?? '').toString(),
        });
      }
    }

    // ==============================
    // 3️⃣ ملف النتيجة
    // ==============================
    final excel = Excel.createExcel();
    final sheet = excel['Result'];

    sheet.appendRow([
      'الرقم',
      'الاسم',
      'الحالة القديمة',
      'الحالة الجديدة',
      'النتيجة',
    ]);

    for (var c in changed) {
      sheet.appendRow([
        c['number'],
        c['name'],
        c['old'],
        c['new'],
        'تغير',
      ]);
    }

    for (var m in missing) {
      sheet.appendRow([
        m['number'],
        m['name'],
        '',
        '',
        'مفقود',
      ]);
    }

    for (var a in added) {
      sheet.appendRow([
        a['number'],
        a['name'],
        '',
        '',
        'جديد',
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
