import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../core/comparison_engine.dart';

class ComparisonExcelExport {

  static Future<String> exportComparison(
    String oldMonth,
    String newMonth,
  ) async {

    final result =
        await ComparisonEngine.compareMonths(
      oldMonth,
      newMonth,
    );

    final excel = Excel.createExcel();

    final sheet = excel['Comparison'];

    // العناوين
    sheet.cell(CellIndex.indexByString("A1"))
        .value = TextCellValue('الرقم العسكري');

    sheet.cell(CellIndex.indexByString("B1"))
        .value = TextCellValue('الحالة السابقة');

    sheet.cell(CellIndex.indexByString("C1"))
        .value = TextCellValue('الحالة الجديدة');

    sheet.cell(CellIndex.indexByString("D1"))
        .value = TextCellValue('النوع');

    int row = 2;

    // المتغيرين
    for (var item in result['changed']) {

      sheet.cell(
        CellIndex.indexByString("A$row"),
      ).value = TextCellValue(
        item['number'].toString(),
      );

      sheet.cell(
        CellIndex.indexByString("B$row"),
      ).value = TextCellValue(
        item['old_status'].toString(),
      );

      sheet.cell(
        CellIndex.indexByString("C$row"),
      ).value = TextCellValue(
        item['new_status'].toString(),
      );

      sheet.cell(
        CellIndex.indexByString("D$row"),
      ).value = TextCellValue('متغير');

      row++;
    }

    // المختفين
    for (var item in result['disappeared']) {

      sheet.cell(
        CellIndex.indexByString("A$row"),
      ).value = TextCellValue(
        item['number'].toString(),
      );

      sheet.cell(
        CellIndex.indexByString("D$row"),
      ).value = TextCellValue('مختفي');

      row++;
    }

    // الجدد
    for (var item in result['added']) {

      sheet.cell(
        CellIndex.indexByString("A$row"),
      ).value = TextCellValue(
        item['number'].toString(),
      );

      sheet.cell(
        CellIndex.indexByString("D$row"),
      ).value = TextCellValue('جديد');

      row++;
    }

    final dir =
        await getApplicationDocumentsDirectory();

    final file = File(
      '${dir.path}/comparison.xlsx',
    );

    final bytes = excel.encode();

    await file.writeAsBytes(bytes!);

    return file.path;
  }
}
