import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../db/db_helper.dart';

class ExportService {

  // =========================
  // Excel Export
  // =========================
  static Future<String?> exportExcel({
    String? year,
    String? status,
    String? unit,
  }) async {

    final db = await DBHelper.database;

    String query = "SELECT * FROM timeline WHERE 1=1";
    List args = [];

    if (year != null) {
      query += " AND year = ?";
      args.add(year);
    }

    if (status != null) {
      query += " AND status = ?";
      args.add(status);
    }

    if (unit != null) {
      query += " AND unit = ?";
      args.add(unit);
    }

    final data = await db.rawQuery(query, args);

    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الاسم"),
      TextCellValue("الرتبة"),
      TextCellValue("الوحدة"),
      TextCellValue("الحالة"),
      TextCellValue("الشهر"),
      TextCellValue("السنة"),
    ]);

    for (var e in data) {
      sheet.appendRow([
        TextCellValue((e['number'] ?? '').toString()),
        TextCellValue((e['name'] ?? '').toString()),
        TextCellValue((e['rank'] ?? '').toString()),
        TextCellValue((e['unit'] ?? '').toString()),
        TextCellValue((e['status'] ?? '').toString()),
        TextCellValue((e['month'] ?? '').toString()),
        TextCellValue((e['year'] ?? '').toString()),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/report.xlsx");

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception("فشل إنشاء ملف Excel");
    }

    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);

    return file.path;
  }

  // =========================
  // PDF Export
  // =========================
  static Future<String?> exportPdf({
    String title = "تقرير رسمي",
    String? year,
    String? status,
    String? unit,
  }) async {

    final db = await DBHelper.database;

    String query = "SELECT * FROM timeline WHERE 1=1";
    List args = [];

    if (year != null) {
      query += " AND year = ?";
      args.add(year);
    }

    if (status != null) {
      query += " AND status = ?";
      args.add(status);
    }

    if (unit != null) {
      query += " AND unit = ?";
      args.add(unit);
    }

    final data = await db.rawQuery(query, args);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text("السنة: ${year ?? 'الكل'}"),
              pw.Text("الحالة: ${status ?? 'الكل'}"),
              pw.Text("الوحدة: ${unit ?? 'الكل'}"),

              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                headers: [
                  "الرقم",
                  "الاسم",
                  "الرتبة",
                  "الوحدة",
                  "الحالة",
                  "الشهر",
                  "السنة",
                ],
                data: data.map((e) {
                  return [
                    (e['number'] ?? '').toString(),
                    (e['name'] ?? '').toString(),
                    (e['rank'] ?? '').toString(),
                    (e['unit'] ?? '').toString(),
                    (e['status'] ?? '').toString(),
                    (e['month'] ?? '').toString(),
                    (e['year'] ?? '').toString(),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("التوقيع: __________"),
                  pw.Text("التوقيع: __________"),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/report.pdf");

    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);

    return file.path;
  }
}
