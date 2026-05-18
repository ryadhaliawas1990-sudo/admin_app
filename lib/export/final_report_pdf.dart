import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class FinalReportPdf {

  /// دالة التصدير الذكية بصيغة ملف ويب رسمي قابل للطباعة الفورية
  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
    bool autoOpen = true,
    bool shareFile = false,
  }) async {

    // تحديد اتجاه الصفحة الافتراضي للطباعة بناءً على عدد الأشهر
    String pageOrientation = months.length > 5 ? "landscape" : "portrait";

    // استخراج بيانات المذكور الأول
    final Map<String, dynamic> person = people.isNotEmpty ? people.first : {};
    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final Map<dynamic, dynamic> monthsMap = (person["months"] ?? {}) as Map<dynamic, dynamic>;

    // بناء جدول الأشهر والحالات ديناميكياً
    String monthsHeaders = "";
    String statusCells = "";

    for (var m in months) {
      monthsHeaders += "<th>$m</th>";
      String statusValue = monthsMap[m]?.toString() ?? "-";
      if (statusValue.trim().toLowerCase() == 'null' || statusValue.trim().isEmpty) {
        statusValue = "-";
      }
      statusCells += "<td>$statusValue</td>";
    }

    // صياغة التصميم العسكري الرسمي للمستند باستخدام HTML5 و CSS3 تضمن تفعيل زر الطباعة التلقائي
    final String htmlContent = """
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
      <meta charset="UTF-8">
      <title>تقرير سجل الحالة الدوري</title>
      <style>
        @media print {
          @page { size: A4 $pageOrientation; margin: 15mm; }
          .no-print { display: none; }
        }
        body { font-family: system-ui, -apple-system, sans-serif; color: #000; padding: 20px; line-height: 1.6; background-color: #fff; }
        .text-center { text-align: center; }
        .title { font-size: 24px; font-weight: bold; margin-bottom: 5px; color: #111; }
        .subtitle { font-size: 14px; margin-bottom: 25px; color: #444; font-weight: bold; }
        
        /* زر الطباعة العلوي للتسهيل على المستخدم */
        .print-btn { 
          background-color: #007bff; color: white; padding: 10px 20px; border: none; 
          border-radius: 5px; font-size: 14px; cursor: pointer; font-weight: bold;
          margin-bottom: 20px; display: inline-block; text-decoration: none;
        }
        
        /* صندوق البيانات الأساسية خارج الجدول */
        .info-box { border: 2px solid #000; padding: 15px; margin-bottom: 25px; background-color: #fff; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-weight: bold; font-size: 15px; }
        
        /* تنسيق الجدول الرسمي الرصين */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; margin-bottom: 40px; }
        th, td { border: 2px solid #000; padding: 12px; text-align: center; font-size: 14px; }
        th { background-color: #eaeaea; font-weight: bold; }
        
        /* قطاع التواقيع السفلي */
        .signature-section { display: flex; justify-content: space-between; margin-top: 60px; font-weight: bold; font-size: 15px; }
        .footer-text { margin-top: 50px; border-top: 1px dashed #000; padding-top: 15px; font-size: 13px; color: #333; }
      </style>
    </head>
    <body>

      <div class="text-center no-print">
        <button class="print-btn" onclick="window.print()">انقر هنا للحفظ بتنسيق PDF أو الطباعة المباشرة 📄</button>
      </div>

      <div class="text-center">
        <div class="title">تقرير سجل الحالة الدوري</div>
        <div class="subtitle">$headerText</div>
      </div>

      <div class="info-box">
        <div class="info-row">
          <div>الرقم العسكري: $pNumber</div>
          <div>الرتبة: $pRank</div>
        </div>
        <div style="font-weight: bold; font-size: 15px; margin-top: 5px;">الاسم الكامل: $pName</div>
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

      <div class="signature-section">
        <div>توقيع مدير القسم: ....................</div>
        <div>توقيع المراجعة: ....................</div>
        <div>توقيع الاعتماد: ....................</div>
      </div>

      ${footerText.isNotEmpty ? '<div class="text-center footer-text">' + footerText + '</div>' : ''}

    </body>
    </html>
    """;

    // 💾 حفظ التقرير بصيغة ملف ويب مستقل في ذاكرة التطبيق
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.html");
    
    await file.writeAsString(htmlContent);
    final path = file.path;

    // 📂 فتح الملف تلقائياً بالمتصفح الافتراضي للهاتف
    if (autoOpen) {
      await OpenFile.open(path);
    }

    // 📤 تفعيل خيار المشاركة
    if (shareFile) {
      await Share.shareXFiles([XFile(path)]);
    }

    return path;
  }
}
