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
    sheet.appendRow([
      'الرقم العسكري',
      'الحالة السابقة',
      'الحالة الجديدة',
      'النوع',
    ]);

    // المتغيرين
    for (var item in result['changed']) {

      sheet.appendRow([

        item['number'],

        item['old_status'],

        item['new_status'],

        'متغير',
      ]);
    }

    // المختفين
    for (var item in result['disappeared']) {

      sheet.appendRow([

        item['number'],

        '',

        '',

        'مختفي',
      ]);
    }

    // الجدد
    for (var item in result['added']) {

      sheet.appendRow([

        item['number'],

        '',

        '',

        'جديد',
      ]);
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
