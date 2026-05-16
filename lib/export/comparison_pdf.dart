import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ComparisonPdf {

  static Future<pw.Document> generate({
    required String title,
    required String instructionText,
    required String personName,
    required String personNumber,
    required String personRank,
    required List<String> months,
    required List<Map<String, String>> rows,
    required String signatureRight,
    required String signatureLeft,
    String? organizationName,
  }) async {

    final pdf = pw.Document();

    // 🟢 الخط العربي
    final fontData = await rootBundle.load(
      "assets/fonts/NotoNaskhArabic-Regular.ttf",
    );
    final ttf = pw.Font.ttf(fontData);

    // 🟢 شعار افتراضي (ضع صورة داخل assets لاحقًا)
    final logoBytes = await rootBundle.load(
      "assets/images/logo.png",
    );
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final isLandscape = months.length > 6;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: isLandscape
            ? PdfPageFormat.a4.landscape
            : PdfPageFormat.a4,

        theme: pw.ThemeData.withFont(base: ttf),

        margin: const pw.EdgeInsets.all(18),

        build: (context) {
          return [

            // 🟢 HEADER مع شعار
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [

                pw.Container(
                  width: 60,
                  height: 60,
                  child: pw.Image(logoImage),
                ),

                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [

                        if (organizationName != null)
                          pw.Text(
                            organizationName,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 6),

                        pw.Text(
                          instructionText,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 12),

            // 🟢 بيانات الشخص
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('الرقم العسكري: $personNumber'),
                  pw.Text('الرتبة: $personRank'),
                  pw.Text('الاسم: $personName'),
                ],
              ),
            ),

            pw.SizedBox(height: 15),

            // 🟢 الجدول
            pw.Table.fromTextArray(
              headers: months,

              data: rows.map((e) {
                return months.map((m) => e[m] ?? '').toList();
              }).toList(),

              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),

              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.black,
              ),

              cellStyle: const pw.TextStyle(
                fontSize: 9,
              ),

              cellAlignment: pw.Alignment.center,

              border: pw.TableBorder.all(
                color: PdfColors.grey700,
                width: 0.5,
              ),
            ),

            pw.SizedBox(height: 25),

            // 🟢 التواقيع (نصوص مدخلة)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('التوقيع: $signatureLeft'),
                      pw.SizedBox(height: 20),
                      pw.Text('_____________________'),
                    ],
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('التوقيع: $signatureRight'),
                      pw.SizedBox(height: 20),
                      pw.Text('_____________________'),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }
}
