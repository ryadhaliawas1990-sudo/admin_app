import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../db/db_helper.dart';

class MonthlyComparisonPdf {

  static Future<String> export(
    List<String> months, {
    List<String>? numbers,
  }) async {

    final pdf = pw.Document();

    Map<String, List<Map<String, dynamic>>> dataByMonth = {};

    for (String month in months) {
      final data = await DBHelper.getByMonth(month);
      dataByMonth[month] = data;
    }

    Map<String, Map<String, dynamic>> peopleMap = {};

    for (var month in months) {
      for (var p in dataByMonth[month]!) {
        final num = p['number'];

        if (numbers != null && !numbers.contains(num)) continue;

        peopleMap[num] = p;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                '📊 تقرير المباينة',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Table(
                border: pw.TableBorder.all(),

                children: [

                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Text("الرقم"),
                      pw.Text("الرتبة"),
                      pw.Text("الاسم"),
                      pw.Text("الوحدة"),
                      ...months.map((m) => pw.Text(m)),
                      pw.Text("النسبة"),
                    ],
                  ),

                  // Rows
                  ...peopleMap.values.map((p) {

                    int present = 0;

                    final row = <pw.Widget>[
                      pw.Text(p['number'] ?? ''),
                      pw.Text(p['rank'] ?? ''),
                      pw.Text(p['name'] ?? ''),
                      pw.Text(p['unit'] ?? ''),
                    ];

                    for (var month in months) {
                      final exists = dataByMonth[month]!
                          .any((e) => e['number'] == p['number']);

                      if (exists) present++;

                      row.add(
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          color: exists ? PdfColors.green100 : PdfColors.red100,
                          child: pw.Text(exists ? "✔" : "✖"),
                        ),
                      );
                    }

                    final percent = (present / months.length * 100).toInt();

                    row.add(pw.Text("$percent%"));

                    return pw.TableRow(children: row);
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // 📁 حفظ تلقائي داخل الجهاز
    final dir = await getApplicationDocumentsDirectory();

    final fileName =
        "mubayana_${months.join('_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";

    final file = File("${dir.path}/$fileName");

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
