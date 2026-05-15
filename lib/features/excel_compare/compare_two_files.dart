import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/excel_reader.dart';
import '../../core/name_matcher.dart';
import '../../screens/comparison_result_screen.dart';

class CompareTwoFiles {

  static Future<void> run(BuildContext context) async {

    // =========================
    // اختيار الملف القديم
    // =========================
    final oldFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (oldFile == null) return;

    // =========================
    // اختيار الملف الجديد
    // =========================
    final newFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (newFile == null) return;

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
    List<Map<String, dynamic>> missing = [];
    List<Map<String, dynamic>> added = [];

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
      // النتيجة
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
    // فتح شاشة النتائج
    // =========================
    if (context.mounted) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComparisonResultScreen(
            changed: changed,
            missing: missing,
            added: added,
          ),
        ),
      );
    }
  }
}
