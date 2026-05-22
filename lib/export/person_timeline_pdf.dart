  }
}
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../db/db_helper.dart';

class PersonTimelinePdf {

  static Future<String?> generate({
    required String number,
    String headerText = "تقرير المباينة",
  }) async {

    final data = await DBHelper.getPersonTimeline(number);

    if (data.isEmpty) return null;

    final name = data.first['name'] ?? '';
    final rank = data.first['rank'] ?? '';

    final isLandscape = data.length > 6;

    final pageFormat = isLandscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              /// =====================
              /// العنوان
              /// =====================
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

              /// =====================
              /// بيانات الفرد
              /// =====================
              pw.Text("الاسم: $name"),
              pw.Text("الرقم: $number"),
              pw.Text("الرتبة: $rank"),

              pw.SizedBox(height: 15),

              /// =====================
              /// الجدول (FIXED)
              /// =====================
              pw.TableHelper.fromTextArray(
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

              pw.SizedBox(height: 25),

              /// =====================
              /// التوقيعات
              /// =====================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("توقيع المسؤول: __________"),
                  pw.Text("توقيع القائد: __________"),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/person_$number.pdf");

    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);

    return file.path;
  }
}
