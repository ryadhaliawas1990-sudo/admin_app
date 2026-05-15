import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../db/db_helper.dart';

class BatchTimelinePdf {

  static Future<String?> generate({
    required List<String> numbers,
    String headerText = "تقرير مباينة جماعي",
  }) async {

    final pdf = pw.Document();

    for (String number in numbers) {

      final data = await DBHelper.getPersonTimeline(number);

      if (data.isEmpty) continue;

      final name = data.first['name'] ?? '';
      final rank = data.first['rank'] ?? '';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,

          build: (context) {

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // =====================
                // العنوان
                // =====================
                pw.Center(
                  child: pw.Text(
                    headerText,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 15),

                // =====================
                // بيانات الفرد
                // =====================
                pw.Text("الاسم: $name"),
                pw.Text("الرقم: $number"),
                pw.Text("الرتبة: $rank"),

                pw.SizedBox(height: 15),

                // =====================
                // الجدول
                // =====================
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(width: 0.5),
                  headers: [
                    "الشهر",
                    "السنة",
                    "الحالة",
                    "الوحدة",
                  ],
                  data: data.map((e) {
                    return [
                      e['month'] ?? '',
                      e['year'] ?? '',
                      e['status'] ?? '',
                      e['unit'] ?? '',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellAlignment: pw.Alignment.center,
                ),

                pw.SizedBox(height: 20),

                pw.Divider(),

              ],
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/batch_report.pdf");

    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);

    return file.path;
  }
}
