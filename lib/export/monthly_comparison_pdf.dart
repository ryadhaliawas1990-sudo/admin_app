import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class MonthlyComparisonPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,

    // 🟢 إضافة نص يدوي أعلى التقرير
    String headerText = "تقرير المباينة",
    String footerLeft = "",
    String footerRight = "",
  }) async {

    final pdf = pw.Document();

    // 🔥 تحميل خط عربي
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,

        theme: pw.ThemeData.withFont(
          base: ttf,
        ),

        textDirection: pw.TextDirection.rtl,

        build: (context) {

          return [

            // 🟢 النص العلوي اليدوي
            pw.Text(
              headerText,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 15),

            // 🟢 الجدول
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),

              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FixedColumnWidth(120),
                2: const pw.FixedColumnWidth(100),
              },

              children: [

                // 🔵 رأس الجدول
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),

                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("الرقم", textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("الاسم", textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("الرتبة", textAlign: pw.TextAlign.center),
                    ),

                    ...months.map((m) => pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(m, textAlign: pw.TextAlign.center),
                    )),
                  ],
                ),

                // 🟢 البيانات
                ...people.map((p) {

                  final monthsMap =
                      (p["months"] ?? {}) as Map<String, dynamic>;

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text((p["number"] ?? "").toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text((p["name"] ?? "").toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text((p["rank"] ?? "").toString()),
                      ),

                      ...months.map((m) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            (monthsMap[m] ?? "-").toString(),
                            textAlign: pw.TextAlign.center,
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 30),

            // 🟢 التواقيع
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [

                pw.Column(
                  children: [
                    pw.Text("التوقيع"),
                    pw.SizedBox(height: 20),
                    pw.Text(footerLeft),
                  ],
                ),

                pw.Column(
                  children: [
                    pw.Text("اعتماد"),
                    pw.SizedBox(height: 20),
                    pw.Text(footerRight),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/comparison_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
