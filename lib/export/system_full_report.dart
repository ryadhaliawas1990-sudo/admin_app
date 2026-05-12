import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class SystemFullReport {

  static Future<String> export({
    required List<Map<String, dynamic>> data,
    required String title,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headers: [
                "الرقم",
                "الاسم",
                "الرتبة",
                "الوحدة",
                "الحالة",
              ],

              data: data.map((e) {
                return [
                  (e["number"] ?? "").toString(),
                  (e["name"] ?? "").toString(),
                  (e["rank"] ?? "").toString(),
                  (e["unit"] ?? "").toString(),
                  (e["status"] ?? "").toString(),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/system_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
