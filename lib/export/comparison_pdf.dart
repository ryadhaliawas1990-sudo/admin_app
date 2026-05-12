import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ComparisonPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> data,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

          return [

            pw.Text(
              "تقرير المباينة العسكرية",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: [
                "الرقم",
                "الاسم",
                "الرتبة",
                ...months,
                "النسبة",
              ],

              data: data.map((p) {

                final monthsMap =
                    (p["months"] as Map?)?.map(
                      (k, v) => MapEntry(k.toString(), v == true),
                    ) ??
                    <String, bool>{};

                int total = monthsMap.length;
                int present =
                    monthsMap.values.where((v) => v).length;

                double percent =
                    total == 0 ? 0 : present / total;

                return [
                  (p["number"] ?? "").toString(),
                  (p["name"] ?? "").toString(),
                  (p["rank"] ?? "").toString(),
                  ...months.map(
                    (m) => (monthsMap[m] ?? false) ? "✔" : "✖",
                  ),
                  "${(percent * 100).toStringAsFixed(0)}%",
                ];
              }).toList(),
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
