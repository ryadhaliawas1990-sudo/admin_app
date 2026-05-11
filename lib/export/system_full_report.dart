import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db/db_helper.dart';

class SystemFullReport {

  static Future<String> generate() async {

    final pdf = pw.Document();

    final people = await DBHelper.getPeople();
    final reports = await DBHelper.getReports();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Text(
            "📊 التقرير الشامل للنظام",
            style: pw.TextStyle(fontSize: 20),
          ),

          pw.SizedBox(height: 20),

          pw.Text("👥 عدد الموظفين: ${people.length}"),
          pw.Text("📁 عدد التقارير: ${reports.length}"),

          pw.SizedBox(height: 20),

          pw.Text("📋 الموظفين:"),

          pw.Table.fromTextArray(
            headers: ["الاسم", "الرقم", "الرتبة"],
            data: people.map((e) {
              return [
                e["name"] ?? "",
                e["number"] ?? "",
                e["rank"] ?? "",
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          pw.Text("📁 التقارير:"),

          pw.Column(
            children: reports.map((r) {
              return pw.Text(
                "• ${r["title"]} - ${r["createdAt"]}",
              );
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/system_full_report.pdf");

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
