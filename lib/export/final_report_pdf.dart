import 'dart:io';
import 'package:printing/printing.dart';

class FinalReportPdf {

  static Future<void> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
  }) async {

    final person = people.isNotEmpty ? people.first : {};

    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final String pUnit = person["unit"]?.toString() ?? "-";

    // =========================
    // بناء صف الحالات
    // =========================
    final statusRow = months.map((m) {
      String statusValue = "-";

      for (var p in people) {
        if (p["month"] == m) {
          statusValue = p["status"]?.toString() ?? "-";
          break;
        }
      }

      return "<td>$statusValue</td>";
    }).join();

    final headers = months.map((m) => "<th>$m</th>").join();

    // =========================
    // HTML كامل
    // =========================
    final html = """
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<style>
  body {
    font-family: Arial;
    direction: rtl;
    text-align: right;
    padding: 20px;
  }

  h2 {
    text-align: center;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
  }

  th, td {
    border: 1px solid #000;
    padding: 8px;
    text-align: center;
  }

  .box {
    border: 1px solid #000;
    padding: 10px;
    margin-top: 15px;
  }
</style>
</head>

<body>

<h2>تقرير سجل الحالة الدوري</h2>

${headerText.isNotEmpty ? "<h4 style='text-align:center;'>$headerText</h4>" : ""}

<div class="box">
  <p>الرقم العسكري: $pNumber</p>
  <p>الرتبة العسكرية: $pRank</p>
  <p>الاسم الكامل: $pName</p>
  <p>الوحدة / التشكيل: $pUnit</p>
</div>

<table>
  <tr>
    $headers
  </tr>
  <tr>
    $statusRow
  </tr>
</table>

<br><br>

<div style="display:flex; justify-content:space-between;">
  <p>توقيع مدير القسم: ............</p>
  <p>توقيع الاعتماد: ............</p>
</div>

${footerText.isNotEmpty ? "<p style='text-align:center;'>$footerText</p>" : ""}

</body>
</html>
""";

    // =========================
    // توليد PDF من HTML
    // =========================
    await Printing.layoutPdf(
      onLayout: (format) async {
        return await Printing.convertHtml(
          format: format,
          html: html,
        );
      },
    );
  }
}
