import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class MonthlyComparisonPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    required Map<String, dynamic> data,
    required String topText,
    required String leftSignature,
    required String rightSignature,
  }) async {

    final pdf = pw.Document();

    // 📌 تحديد الاتجاه حسب عدد الأشهر
    final bool isLandscape = months.length > 5;

    final PdfPageFormat pageFormat =
        isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        build: (context) {

          return [

            // 🟢 العنوان العلوي
            pw.Text(
              topText,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            // 👤 بيانات الأشخاص
            ...people.map((p) {

              final number = p["number"]?.toString() ?? "";

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    pw.Text("الرتبة: ${p["rank"] ?? "-"}"),
                    pw.Text("الرقم: $number"),
                    pw.Text(
                      "الاسم: ${p["name"] ?? "-"}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 8),

                    // 📊 الجدول
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [

                        // العناوين (الأشهر)
                        pw.TableRow(
                          children: months.map((m) {
                            return pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                m,
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),

                        // الصف (الحالات)
                        pw.TableRow(
                          children: months.map((m) {

                            final status = data[number]?["months"]?[m] ?? "-";

                            return pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                status,
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 30),

            // ✍️ التواقيع
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [

                pw.Column(
                  children: [
                    pw.Text(leftSignature),
                    pw.SizedBox(height: 20),
                    pw.Text("____________"),
                  ],
                ),

                pw.Column(
                  children: [
                    pw.Text(rightSignature),
                    pw.SizedBox(height: 20),
                    pw.Text("____________"),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    // 💾 حفظ الملف
    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/monthly_comparison_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
