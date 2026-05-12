import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class ExcelCompare {

  static Future<Map<String, dynamic>> compareFiles() async {

    List<List<Map<String, dynamic>>> filesData = [];

    // 📁 اختيار عدة ملفات
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return {};

    for (var file in result.files) {

      var bytes = File(file.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> data = [];

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;

        for (var row in rows.skip(1)) {
          data.add({
            "number": row[0]?.value?.toString() ?? "",
            "name": row[1]?.value?.toString() ?? "",
          });
        }
      }

      filesData.add(data);
    }

    // =========================
    // 🔁 استخراج المشترك
    // =========================

    if (filesData.isEmpty) {
      return {
        "common": [],
        "different": [],
      };
    }

    Set<String> common = filesData.first
        .map((e) => e["number"].toString())
        .toSet();

    for (var file in filesData) {
      common = common.intersection(
        file.map((e) => e["number"].toString()).toSet(),
      );
    }

    // =========================
    // ❌ استخراج المختلف
    // =========================

    Set<String> all = <String>{};

    for (var file in filesData) {
      all.addAll(
        file.map((e) => e["number"].toString()),
      );
    }

    Set<String> different = all.difference(common);

    return {
      "common": common.toList(),
      "different": different.toList(),
    };
  }
}
