import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';

class FinalReportExcel {

  static Future<void> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
  }) async {

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];

    sheet.name = 'تقرير الحالة';

    final person = people.isNotEmpty ? people.first : {};

    // =====================
    // بيانات الفرد
    // =====================
    sheet.getRangeByName('A1').setText('الرقم العسكري');
    sheet.getRangeByName('B1').setText(person["number"]?.toString() ?? "-");

    sheet.getRangeByName('A2').setText('الرتبة');
    sheet.getRangeByName('B2').setText(person["rank"]?.toString() ?? "-");

    sheet.getRangeByName('A3').setText('الاسم');
    sheet.getRangeByName('B3').setText(person["name"]?.toString() ?? "-");

    sheet.getRangeByName('A4').setText('الوحدة');
    sheet.getRangeByName('B4').setText(person["unit"]?.toString() ?? "-");

    // =====================
    // العناوين (الشهور)
    // =====================
    for (int i = 0; i < months.length; i++) {
      sheet.getRangeByIndex(6, i + 2).setText(months[i]);
    }

    // =====================
    // القيم
    // =====================
    for (int i = 0; i < months.length; i++) {

      String value = "-";

      for (var p in people) {
        if (p["month"] == months[i]) {
          value = p["status"]?.toString() ?? "-";
          break;
        }
      }

      sheet.getRangeByIndex(7, i + 2).setText(value);
    }

    // =====================
    // حفظ الملف
    // =====================
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/final_report.xlsx');

    await file.writeAsBytes(bytes);

    print("Excel saved at: ${file.path}");
  }
}
