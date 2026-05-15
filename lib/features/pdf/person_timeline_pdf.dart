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

    // تحديد الاتجاه حسب عدد السجلات
    final bool landscape = timeline.length > 12;

    pdf.addPage(

      pw.MultiPage(

        pageFormat: landscape
            ? PdfPageFormat.a4.landscape
            : PdfPageFormat.a4,

        build: (context) {

          return [

            // النص العلوي
            if (topText.isNotEmpty)

              pw.Container(
                margin:
                    const pw.EdgeInsets.only(bottom: 20),

                child: pw.Text(
                  topText,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),

            // معلومات الشخص
            pw.Container(

              padding: const pw.EdgeInsets.all(10),

              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),

              child: pw.Column(

                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,

                children: [

                  pw.Text(
                    'الاسم: $name',
                    textDirection:
                        pw.TextDirection.rtl,
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    'الرقم: $number',
                    textDirection:
                        pw.TextDirection.rtl,
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    'الرتبة: $rank',
                    textDirection:
                        pw.TextDirection.rtl,
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    'الوحدة: $unit',
                    textDirection:
                        pw.TextDirection.rtl,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // الجدول
            pw.Table.fromTextArray(

              headerDirection:
                  pw.TextDirection.rtl,

              cellAlignment:
                  pw.Alignment.center,

              headers: [
                'السنة',
                'الشهر',
                'الحالة',
              ],

              data: timeline.map((item) {

                return [

                  item['year']
                          ?.toString() ??
                      '',

                  item['month']
                          ?.toString() ??
                      '',

                  item['status']
                          ?.toString() ??
                      '',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 40),

            // التواقيع
            pw.Row(

              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,

              children: [

                pw.Text(
                  leftSign,
                  textDirection
