import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class MonthlyComparisonPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

          return [

            pw.Text(
              "تقرير المباينة",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

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
                      pw.Text((p["number"] ?? "").toString()),
                      pw.Text((p["name"] ?? "").toString()),
                      pw.Text((p["rank"] ?? "").toString()),

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
