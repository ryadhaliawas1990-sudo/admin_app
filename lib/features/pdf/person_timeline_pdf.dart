import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PersonTimelinePdf {

  static Future<void> generate({

    required String name,
    required String number,
    required String rank,
    required String unit,
    required List<Map<String, dynamic>> timeline,

    String topText = '',
    String rightSign = '',
    String leftSign = '',

  }) async {

    final pdf = pw.Document();

    final isLandscape = timeline.length > 12;

    pdf.addPage(

      pw.MultiPage(

        pageFormat: isLandscape
            ? PdfPageFormat.a4.landscape
            : PdfPageFormat.a4,

        build: (context) {

          return [

            // العنوان
            if (topText.isNotEmpty)
              pw.Text(
                topText,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

            pw.SizedBox(height: 20),

            // بيانات الفرد
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  pw.Text('الاسم: $name'),
                  pw.Text('الرقم: $number'),
                  pw.Text('الرتبة: $rank'),
                  pw.Text('الوحدة: $unit'),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // الجدول
            pw.TableHelper.fromTextArray(

              headers: ['السنة', 'الشهر', 'الحالة'],

              data: timeline.map((item) {
                return [
                  item['year']?.toString() ?? '',
                  item['month']?.toString() ?? '',
                  item['status']?.toString() ?? '',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 30),

            // التواقيع
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [

                pw.Text(leftSign),

                pw.Text(rightSign),
              ],
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/timeline_report.pdf');

    await file.writeAsBytes(await pdf.save());

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
