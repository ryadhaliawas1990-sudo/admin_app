class FinalReportHtml {

  static String build({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
  }) {

    final person = people.isNotEmpty ? people.first : {};

    final pNumber = person["number"] ?? "-";
    final pName = person["name"] ?? "-";
    final pRank = person["rank"] ?? "-";
    final pUnit = person["unit"] ?? "-";

    final headers = months.map((m) => "<th>$m</th>").join();

    final statusRow = months.map((m) {
      String value = "-";
      for (var p in people) {
        if (p["month"] == m) {
          value = p["status"] ?? "-";
          break;
        }
      }
      return "<td>$value</td>";
    }).join();

    return """
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<style>
  body {
    font-family: Arial;
    direction: rtl;
    padding: 20px;
    text-align: right;
  }

  h2 {
    text-align: center;
    margin-bottom: 10px;
  }

  .box {
    border: 1px solid #000;
    padding: 10px;
    margin: 10px 0;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
  }

  th, td {
    border: 1px solid #000;
    padding: 8px;
    text-align: center;
  }

  .footer {
    margin-top: 30px;
    display: flex;
    justify-content: space-between;
  }
</style>
</head>

<body>

<h2>تقرير سجل الحالة الدوري</h2>

${headerText.isNotEmpty ? "<p style='text-align:center;'>$headerText</p>" : ""}

<div class="box">
  <p>الرقم العسكري: $pNumber</p>
  <p>الرتبة: $pRank</p>
  <p>الاسم: $pName</p>
  <p>الوحدة: $pUnit</p>
</div>

<table>
  <tr>$headers</tr>
  <tr>$statusRow</tr>
</table>

<div class="footer">
  <p>توقيع مدير القسم: ............</p>
  <p>توقيع الاعتماد: ............</p>
</div>

${footerText.isNotEmpty ? "<p style='text-align:center;'>$footerText</p>" : ""}

</body>
</html>
""";
  }
}
