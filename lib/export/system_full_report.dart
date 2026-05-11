import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../db/db_helper.dart';

class SystemFullReport {

  static Future<String> generate() async {

    final pdf = pw.Document();

    final people = await DBHelper.getPeople();
    final reports = await DBHelper.getReports();
    final logs = await DBHelper.getLogs();

    final date = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Text(
              "📊 تقرير النظام الكامل",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text("📅 التاريخ: ${date.toIso8601String()}"),

            pw.SizedBox(height: 20),

            pw.Text("👥 عدد الموظفين: ${people.length}"),
            pw.Text("📄 عدد التقارير: ${reports.length}"),
            pw.Text("🧠 عدد العمليات: ${logs.length}"),

            pw.SizedBox(height: 20),

            pw.Text(
              "🧠 آخر العمليات:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            ...logs.take(10).map(
              (log) => pw.Text(
                "- ${log['action']} | ${log['createdAt']}",
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/system_report_${date.millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
