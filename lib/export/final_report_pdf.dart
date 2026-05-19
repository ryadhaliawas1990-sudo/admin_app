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

    String monthsHeaders = "";
    String statusCells = "";

    for (var m in months) {
      monthsHeaders += "<th style='border: 1px solid #000; padding: 10px; background-color: #f5f5f5;'>$m</th>";
      
      String statusValue = "-";
      for (var p in people) {
        if (p["month"] == m) {
          statusValue = p["status"]?.toString() ?? "-";
          break;
        }
      }
      statusCells += "<td style='border: 1px solid #000; padding: 10px; text-align: center; font-weight: bold;'>$statusValue</td>";
    }

    // 🎨 تم جلب خط Cairo مباشرة من سيرفرات جوجل لحسم مشكلة المربعات في الأندرويد نهائياً
    final String htmlContent = """
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
      <meta charset="utf-8">
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;700&display=swap" rel="stylesheet">
      <style>
        body { 
          font-family: 'Cairo', sans-serif; 
          margin: 40px; 
          color: #000;
          background-color: #fff;
        }
        .title { 
          text-align: center; 
          font-size: 26px; 
          font-weight: bold; 
          margin-bottom: 5px;
        }
        .subtitle { 
          text-align: center; 
          font-size: 16px; 
          margin-bottom: 30px;
          color: #444;
        }
        .info-box { 
          border: 2px solid #000; 
          padding: 15px; 
          margin-bottom: 30px;
          line-height: 1.8;
        }
        .info-row { 
          display: flex; 
          justify-content: space-between; 
        }
        .info-item { 
          font-size: 16px; 
          width: 48%;
        }
        table { 
          width: 100%; 
          border-collapse: collapse; 
          margin-top: 25px; 
          font-size: 16px;
        }
        .signatures { 
          display: flex; 
          justify-content: space-between; 
          margin-top: 80px; 
          font-size: 16px;
        }
      </style>
    </head>
    <body>

      <div class="title">تقرير سجل الحالة الدوري</div>
      <div class="subtitle">${headerText.isNotEmpty ? headerText : ""}</div>

      <div class="info-box">
        <div class="info-row">
          <div class="info-item"><strong>الرقم العسكري:</strong> $pNumber</div>
          <div class="info-item"><strong>الرتبة العسكرية:</strong> $pRank</div>
        </div>
        <div class="info-row" style="margin-top: 10px;">
          <div class="info-item"><strong>الاسم الكامل:</strong> $pName</div>
          <div class="info-item"><strong>الوحدة / التشكيل:</strong> $pUnit</div>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            $monthsHeaders
          </tr>
        </thead>
        <tbody>
          <tr>
            $statusCells
          </tr>
        </tbody>
      </table>

      <div class="signatures">
        <div>توقيع مدير القسم: ....................</div>
        <div>توقيع الاعتماد الحتمي: ....................</div>
      </div>

      ${footerText.isNotEmpty ? "<div style='text-align: center; margin-top: 60px; font-size: 14px; border-top: 1px dashed #ccc; padding-top: 10px;'>$footerText</div>" : ""}

    </body>
    </html>
    """;

    await Printing.layoutPdf(
      onLayout: (format) async => await Printing.convertHtml(
        format: format,
        html: htmlContent,
      ),
      name: 'تقرير_عسكري_$pNumber',
    );
  }
}
