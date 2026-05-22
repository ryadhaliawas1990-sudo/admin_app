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

                pw.Text("الاسم: $name"),
                pw.Text("الرقم: $number"),
                pw.Text("الرتبة: $rank"),

                pw.SizedBox(height: 15),

                /// =========================
                /// FIXED TABLE (stable version)
                /// =========================
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(),
                    1: const pw.FlexColumnWidth(),
                    2: const pw.FlexColumnWidth(),
                    3: const pw.FlexColumnWidth(),
                  },
                  children: [

                    /// Headers
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("الشهر",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("السنة",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("الحالة",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text("الوحدة",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),

                    /// Data rows
                    ...data.map((e) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(e['month'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(e['year'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(e['status'] ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(e['unit'] ?? ''),
                          ),
                        ],
                      );
                    }),
                  ],
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
