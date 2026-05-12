import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../db/db_helper.dart';

class CommandReportPdf {

  static Future<String> generate({
    required String from,
    required String to,
    required List<String> months,
    required String unit,
  }) async {

    final pdf = pw.Document();

    final people = await DBHelper.getPeople();

    Map<String, Map<String, bool>> data = {};

    for (final p in people) {
      if (unit != "الكل" && p["unit"] != unit) continue;

      final number = p["number"];
      data[number] = {};

      for (final m in months) {
        final monthData = await DBHelper.getByMonth(m);

        data[number]![m] =
            monthData.any((e) => e["number"] == number);
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
                "📌 تقرير قيادة مباينة",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Text("الوحدة: $unit"),
              pw.Text("من: $from إلى: $to"),

              pw.SizedBox(height: 10),

              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text("التوجيه: .................................."),
              ),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [

                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Text("الرقم"),
                      pw.Text("الاسم"),
                      ...months.map((m) => pw.Text(m)),
                      pw.Text("%"),
                    ],
                  ),

                  ...data.entries.map((e) {

                    final values = e.value;
                    final present =
                        values.values.where((v) => v).length;

                    final percent = values.isEmpty
                        ? 0
                        : (present / values.length * 100).toInt();

                    return pw.TableRow(
                      children: [
                        pw.Text(e.key),

                        pw.Text(
                          people.firstWhere(
                            (p) => p["number"] == e.key,
                            orElse: () => {"name": ""},
                          )["name"],
                        ),

                        ...months.map((m) => pw.Text(
                              values[m] == true ? "✔" : "✖",
                            )),

                        pw.Text("$percent%"),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("القائد: ............"),
                  pw.Text("التوقيع: ............"),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/command_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
