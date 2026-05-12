import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../db/db_helper.dart';

class CommandComparisonPdf {

  static Future<String> generate({
    required String from,
    required String to,
    required List<String> months,
    required String unit,
    String directive = "",
  }) async {

    final pdf = pw.Document();

    final people = await DBHelper.getPeople();

    final filtered = unit == "الكل"
        ? people
        : people.where((p) => p["unit"] == unit).toList();

    Map<String, Map<String, bool>> data = {};

    for (final p in filtered) {
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

              // 🪖 العنوان
              pw.Center(
                child: pw.Text(
                  "تقرير مباينة قيادة عسكري",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text("الفترة: $from → $to"),
              pw.Text("الوحدة: $unit"),

              pw.SizedBox(height: 10),

              // ✍️ التوجيه
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Text(
                  directive.isEmpty
                      ? "التوجيه: ........................................"
                      : "التوجيه: $directive",
                ),
              ),

              pw.SizedBox(height: 10),

              // 📊 الجدول
              pw.Table(
                border: pw.TableBorder.all(),
                children: [

                  // HEADER
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Text("الرقم"),
                      pw.Text("الاسم"),
                      pw.Text("الرتبة"),
                      ...months.map((m) => pw.Text(m)),
                      pw.Text("%"),
                    ],
                  ),

                  // ROWS
                  ...data.entries.map((e) {

                    final person = filtered.firstWhere(
                      (p) => p["number"] == e.key,
                      orElse: () => {},
                    );

                    final values = e.value;
                    final total = values.length;
                    final present =
                        values.values.where((v) => v).length;

                    final percent = total == 0
                        ? 0
                        : (present / total * 100).toInt();

                    return pw.TableRow(
                      children: [
                        pw.Text(e.key),
                        pw.Text(person["name"] ?? ""),
                        pw.Text(person["rank"] ?? ""),

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

              // 🪖 التوقيع
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("القائد: ...................."),
                  pw.Text("التوقيع: ...................."),
                ],
              ),

              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text(
                  "ختم الوحدة",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/command_comparison_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
