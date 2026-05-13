import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class MonthlyExcelImport {

  static Future<Map<String, List<Map<String, dynamic>>>> importByMonth() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.isEmpty) {
      return {};
    }

    final file = result.files.first;
    final bytes = File(file.path!).readAsBytesSync();

    final excel = Excel.decodeBytes(bytes);

    Map<String, List<Map<String, dynamic>>> dataByMonth = {};

    for (var table in excel.tables.keys) {

      final sheet = excel.tables[table];

      if (sheet == null) continue;

      for (int i = 1; i < sheet.rows.length; i++) {

        final row = sheet.rows[i];

        final number = row[0]?.value?.toString() ?? "";
        final name = row[1]?.value?.toString() ?? "";
        final month = row[2]?.value?.toString() ?? "";
        final status = row[3]?.value?.toString() ?? "";

        if (month.isEmpty) continue;

        dataByMonth.putIfAbsent(month, () => []);

        dataByMonth[month]!.add({
          "number": number,
          "name": name,
          "status": status,
        });
      }
    }

    return dataByMonth;
  }
}
