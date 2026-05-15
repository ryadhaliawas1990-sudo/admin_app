import 'package:excel/excel.dart';

class ExcelReader {

  static List<Map<String, dynamic>> readData(Sheet sheet) {

    final rows = sheet.rows;

    if (rows.isEmpty) return [];

    final header = rows.first;

    List<String> keys = [];

    for (var cell in header) {
      keys.add(cell?.value.toString() ?? '');
    }

    List<Map<String, dynamic>> data = [];

    for (int i = 1; i < rows.length; i++) {

      final row = rows[i];

      Map<String, dynamic> item = {};

      for (int j = 0; j < keys.length; j++) {

        if (j < row.length) {
          item[keys[j]] = row[j]?.value.toString() ?? '';
        }
      }

      data.add(item);
    }

    return data;
  }
}
