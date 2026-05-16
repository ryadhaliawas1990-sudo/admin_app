import 'dart:io';
import 'package:html/parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class MonthlyComparisonPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
  }) async {

    final pdf = pw.Document();

    final htmlContent = StringBuffer();

    htmlContent.write('''
    <html dir="rtl">
    <head>
      <style>
        body { font-family: Arial; direction: rtl; text-align: right; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid black; padding: 5px; text-align: center; }
        th { background: #eee; }
      </style>
    </head>
    <body>
      <h2>تقرير المباينة</h2>

      <table>
        <tr>
          <th>الرقم</th>
          <th>الاسم</th>
          <th>الرتبة</th>
''');

    for (final m in months) {
      htmlContent.write('<th>$m</th>');
    }

    htmlContent.write('</tr>');

    for (final p in people) {

      final monthsMap = (p["months"] ?? {}) as Map<String, dynamic>;

      htmlContent.write('<tr>');
      htmlContent.write('<td>${p["number"] ?? ""}</td>');
      htmlContent.write('<td>${p["name"] ?? ""}</td>');
      htmlContent.write('<td>${p["rank"] ?? ""}</td>');

      for (final m in months) {
        htmlContent.write('<td>${monthsMap[m] ?? "-"}</td>');
      }

      htmlContent.write('</tr>');
    }

    htmlContent.write('</table></body></html>');

    // تحويل HTML إلى PDF
    final pdfData = await Printing.convertHtml(
      format: PdfPageFormat.a4.landscape,
      html: htmlContent.toString(),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(pdfData);

    return file.path;
  }
}
