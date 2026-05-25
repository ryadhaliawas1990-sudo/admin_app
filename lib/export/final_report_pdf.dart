import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class FinalReportPdf {

  static Future<void> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
  }) async {

    final pdf = pw.Document();

    // =========================
    // تحميل الخط العربي
    // =========================
    final fontData = await rootBundle.load(
      "assets/fonts/Cairo-Regular.ttf",
    );

    final ttf = pw.Font.ttf(fontData);

    final person = people.isNotEmpty ? people.first : {};

    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final String pUnit = person["unit"]?.toString() ?? "-";

    // =========================
    // تجهيز أعمدة الشهور
    // =========================
    final headers = months;

    // =========================
    // بناء صف الحالات
    // =========================
    final statusRow = months.map((m) {
      String statusValue = "-";

      for (var p in people) {
        if (p["month"] == m) {
          statusValue = p["status"]?.toString() ?? "-";
          break;
        }
      }

      return statusValue;
    }).toList();

    // =========================
    // إنشاء الصفحة
    // =========================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {

          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // =====================
                // العنوان
                // =====================
                pw.Center(
                  child: pw.Text(
                    "تقرير سجل الحالة الدوري",
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                if (headerText.isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      headerText,
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 14,
                      ),
                    ),
                  ),

                pw.SizedBox(height: 20),

                // =====================
                // بيانات الفرد
                // =====================
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [

                      pw.Text(
                        "الرقم العسكري: $pNumber",
                        style: pw.TextStyle(font: ttf),
                      ),

                      pw.Text(
                        "الرتبة العسكرية: $pRank",
                        style: pw.TextStyle(font: ttf),
                      ),

                      pw.Text(
                        "الاسم الكامل: $pName",
                        style: pw.TextStyle(font: ttf),
                      ),

                      pw.Text(
                        "الوحدة / التشكيل: $pUnit",
                        style: pw.TextStyle(font: ttf),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // =====================
                // جدول الشهور والحالات
                // =====================
                pw.TableHelper.fromTextArray(
                  headers: headers,
                  data: [statusRow],
                  border: pw.TableBorder.all(width: 0.5),

                  headerStyle: pw.TextStyle(
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),

                  cellStyle: pw.TextStyle(
                    font: ttf,
                  ),

                  headerAlignment: pw.Alignment.center,
                  cellAlignment: pw.Alignment.center,
                ),

                pw.SizedBox(height: 30),

                // =====================
                // التوقيعات
                // =====================
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "توقيع مدير القسم: ............",
                      style: pw.TextStyle(font: ttf),
                    ),

                    pw.Text(
                      "توقيع الاعتماد: ............",
                      style: pw.TextStyle(font: ttf),
                    ),
                  ],
                ),

                if (footerText.isNotEmpty) ...[
                  pw.SizedBox(height: 40),
                  pw.Center(
                    child: pw.Text(
                      footerText,
                      textDirection: pw.TextDirection.rtl,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    // =========================
    // حفظ وفتح الملف
    // =========================
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/final_report.pdf");

    await file.writeAsBytes(await pdf.save());

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'final_report_$pNumber',
    );
  }
}
