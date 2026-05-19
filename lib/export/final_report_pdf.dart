import 'package:printing/printing.dart';
import 'package:html/parser.dart' show parse;

class FinalReportPdf {

  /// 🚀 دالة التصدير الذكية عبر محرك نظام الأندرويد الرسمي (الخطة ج)
  static Future<void> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
  }) async {

    // جلب بيانات الفرد الأساسية
    final person = people.isNotEmpty ? people.first : {};
    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final String pUnit = person["unit"]?.toString() ?? "-";

    // 📊 توليد أسطر الجدول ديناميكياً بناءً على الأشهر والحالات الممررة
    String monthsHeaders = "";
    String statusCells = "";

    for (var m in months) {
      monthsHeaders += "<th style='border: 1px solid black; padding: 8px; background-color: #f2f2f2;'>$m</th>";
      
      // البحث عن حالة الشخص في هذا الشهر المحدود
      String statusValue = "-";
      for (var p in people) {
        if (p["month"] == m) {
          statusValue = p["status"]?.toString() ?? "-";
          break;
        }
      }
      statusCells += "<td style='border: 1px solid black; padding: 8px; text-align: center;'>$statusValue</td>";
    }

    // 🎨 صياغة مستند الـ HTML العسكري المنسق والمحاذي بالكامل من اليمين لليسار (RTL)
    final String htmlContent = """
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
      <meta charset="utf-8">
      <style>
        body { 
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
          margin: 30px; 
          color: #000;
        }
        .title { 
          text-align: center; 
          font-size: 24px; 
          font-weight: bold; 
          margin-bottom: 5px;
        }
        .subtitle { 
          text-align: center; 
          font-size: 16px; 
          margin-bottom: 25px;
        }
        .info-box { 
          border: 2px solid #000; 
          padding: 15px; 
          margin-bottom: 25px;
          line-height: 1.6;
        }
        .info-row { 
          display: flex; 
          justify-content: space-between; 
          margin-bottom: 10px;
        }
        .info-item { 
          font-size: 16px; 
          width: 48%;
        }
        table { 
          width: 100%; 
          border-collapse: collapse; 
          margin-top: 20px; 
          font-size: 16px;
        }
        .signatures { 
          display: flex; 
          justify-content: space-between; 
          margin-top: 60px; 
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
          <div class="info-item"><strong>الرتبة:</strong> $pRank</div>
        </div>
        <div class="info-row">
          <div class="info-item"><strong>الاسم:</strong> $pName</div>
          <div class="info-item"><strong>الوحدة:</strong> $pUnit</div>
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
        <div>توقيع الاعتماد: ....................</div>
      </div>

      ${footerText.isNotEmpty ? "<div style='text-align: center; margin-top: 5px; font-size: 14px;'>$footerText</div>" : ""}

    </body>
    </html>
    """;

    // 🚀 الأمر الحاسم: إرسال الـ HTML مباشرة لمحرك طباعة أندرويد ليتولى التوليد بنقاء 100%
    await Printing.layoutPdf(
      onLayout: (format) async => await Printing.convertHtml(
        format: format,
        html: htmlContent,
      ),
      name: 'status_report_$pNumber',
    );
  }
}
