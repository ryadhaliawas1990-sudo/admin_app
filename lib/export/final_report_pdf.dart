import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class FinalReportPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
    bool autoOpen = true,
    bool shareFile = false,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

          return [

            // 🟢 العنوان
            pw.Center(
              child: pw.Column(
                children: [

                  pw.Text(
                    "تقرير المباينة النهائي",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  if (headerText.isNotEmpty)
                    pw.Text(
                      headerText,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 15),

            // 🧾 الجدول
            pw.Table(
              border: pw.TableBorder.all(),
              children: [

                pw.TableRow(
                  children: [
                    pw.Text("الرقم"),
                    pw.Text("الاسم"),
                    pw.Text("الرتبة"),
                    ...months.map((m) => pw.Text(m)),
                  ],
                ),

                ...people.map((p) {

                  final monthsMap =
                      (p["months"] ?? {}) as Map<String, dynamic>;

                  return pw.TableRow(
                    children: [

                      pw.Text(p["number"] ?? ""),
                      pw.Text(p["name"] ?? ""),
                      pw.Text(p["rank"] ?? ""),

                      ...months.map((m) {
                        return pw.Text(
                          (monthsMap[m] ?? "-").toString(),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            // ✍️ التواقيع
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("مدير القسم"),
                pw.Text("المراجعة"),
                pw.Text("الاعتماد"),
              ],
            ),

            if (footerText.isNotEmpty)
              pw.SizedBox(height: 10),

            if (footerText.isNotEmpty)
              pw.Center(child: pw.Text(footerText)),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    final path = file.path;

    // 📂 فتح تلقائي
    if (autoOpen) {
      await OpenFile.open(path);
    }

    // 📤 مشاركة
    if (shareFile) {
      await Share.shareXFiles([XFile(path)]);
    }

    return path;
  }
}
