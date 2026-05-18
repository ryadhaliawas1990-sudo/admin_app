import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart'; // حاسمة جداً لتحويل الـ HTML إلى PDF رسمي

class FinalReportPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
    bool autoOpen = true,
    bool shareFile = false,
  }) async {

    // 1. تحديد اتجاه الصفحة ديناميكياً بناءً على عدد الأشهر
    String pageOrientation = "portrait";
    if (months.length > 5) {
      pageOrientation = "landscape";
    }

    // استخراج بيانات المذكور
    final Map<String, dynamic> person = people.isNotEmpty ? people.first : {};
    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final Map<dynamic, dynamic> monthsMap = (person["months"] ?? {}) as Map<dynamic, dynamic>;

    // 2. بناء جدول الحالات ديناميكياً بصيغة HTML
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

    // 3. صياغة المستند الكامل بتقنية HTML5 و CSS3 لدعم اللغة العربية وتناسق المظهر العسكري
    final String htmlContent = """
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
      <meta charset="UTF-8">
      <style>
        @page { size: A4 $pageOrientation; margin: 20mm; }
        body { font-family: system-ui, -apple-system, sans-serif; color: #000; padding: 10px; line-height: 1.6; }
        .text-center { text-align: center; }
        .title { font-size: 22px; font-weight: bold; margin-bottom: 5px; }
        .subtitle { font-size: 14px; margin-bottom: 25px; color: #333; }
        
        /* صندوق البيانات الأساسية */
        .info-box { border: 1px solid #999; padding: 15px; margin-bottom: 25px; background-color: #fafafa; }
        .info-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-weight: bold; font-size: 14px; }
        
        /* تنسيق الجدول الرسمي */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; margin-bottom: 30px; }
        th, td { border: 1px solid #000; padding: 10px; text-align: center; font-size: 13px; }
        th { background-color: #f0f0f0; font-weight: bold; }
        
        /* قطاع التواقيع */
        .signature-section { display: flex; justify-content: space-between; margin-top: 50px; font-weight: bold; font-size: 14px; }
        .footer-text { margin-top: 40px; border-top: 1px dashed #ccc; padding-top: 10px; font-size: 12px; color: #555; }
      </style>
    </head>
    <body>

      <div class="text-center">
        <div class="title">تقرير سجل الحالة الدوري</div>
        <div class="subtitle">$headerText</div>
      </div>

      <div class="info-box">
        <div class="info-row">
          <div>الرقم العسكري: $pNumber</div>
          <div>الرتبة: $pRank</div>
        </div>
        <div style="font-weight: bold; font-size: 14px;">الاسم الكامل: $pName</div>
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

    // 4. المحرك السحري: تحويل كود الـ HTML إلى ملف PDF رسمي باستخدام تعريفات الهاتف الذاتي
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/status_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    
    // توليد بايتات الـ PDF مباشرة عبر محرك الطباعة النظامي (يدعم العربية تلقائياً بنسبة 100%)
    final pdfBytes = await Printing.convertHtml(
      html: htmlContent,
      format: PdfPageFormat.a4,
    );

    await file.writeAsBytes(pdfBytes);
    final path = file.path;

    // 📂 الفتح التلقائي والمشاركة
    if (autoOpen) {
      await OpenFile.open(path);
    }

    if (shareFile) {
      await Share.shareXFiles([XFile(path)]);
    }

    return path;
  }
}
