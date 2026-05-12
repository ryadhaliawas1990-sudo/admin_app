import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ComparisonReportExport {

  // =========================
  // 📄 PDF EXPORT
  // =========================
  static Future<String> exportPdf({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    required Map<String, List<Map<String, dynamic>>> dataByMonth,
    required String title,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

          return [

            pw.Text(
              title,
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
                ...months,
              ],

              data: people.map((p) {

                return [
                  (p["number"] ?? "").toString(),
                  (p["name"] ?? "").toString(),

                  ...months.map((m) {

                    final monthData = dataByMonth[m] ?? [];

                    final exists = monthData.any(
                      (e) => e["number"] == p["number"],
                    );

                    return exists ? "✔" : "✖";
                  }),
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

  // =========================
  // 📊 EXCEL EXPORT (CSV بسيط)
  // =========================
  static Future<String> exportExcel({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    required Map<String, List<Map<String, dynamic>>> dataByMonth,
  }) async {

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/comparison_${DateTime.now().millisecondsSinceEpoch}.csv",
    );

    final buffer = StringBuffer();

    // header
    buffer.writeln("الرقم,الاسم,${months.join(",")}");

    for (var p in people) {

      final row = <String>[];

      row.add((p["number"] ?? "").toString());
      row.add((p["name"] ?? "").toString());

      for (var m in months) {

        final monthData = dataByMonth[m] ?? [];

        final exists = monthData.any(
          (e) => e["number"] == p["number"],
        );

        row.add(exists ? "1" : "0");
      }

      buffer.writeln(row.join(","));
    }

    await file.writeAsString(buffer.toString());

    return file.path;
  }
}
