import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FinalReportPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
  }) async {

    final pdf = pw.Document();

    // 🎯 الحل النهائي للمربعات: تحميل ملف خط مدمج يدعم العربية بالكامل (تأكد من وجود الملف في مجلد الحزم)
    final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    // إعداد التنسيقات الإلزامية بالخط المدمج لقطع دابر المربعات
    final arabicStyle = pw.TextStyle(font: ttf, fontSize: 13);
    final titleStyle = pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold);

    // تحديد اتجاه المستند تلقائياً
    PdfPageFormat pageFormat = months.length > 5 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4.portrait;

    final person = people.isNotEmpty ? people.first : {};
    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final String pUnit = person["unit"]?.toString() ?? "-";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        textDirection: pw.TextDirection.rtl, // اتجاه عام من اليمين لليسار
        build: (context) => [
          pw.Center(child: pw.Text("تقرير سجل الحالة الدوري", style: titleStyle)),
          pw.SizedBox(height: 10),
          if (headerText.isNotEmpty) pw.Center(child: pw.Text(headerText, style: arabicStyle)),
          pw.SizedBox(height: 20),

          // صندوق البيانات الأساسية خارج الجدول المعالج من التداخل
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Container(
              border: pw.Border.all(color: PdfColors.black, width: 1),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                cross: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("الرقم العسكري: $pNumber", style: arabicStyle),
                      pw.Text("الرتبة: $pRank", style: arabicStyle),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("الاسم: $pName", style: arabicStyle),
                      pw.Text("الوحدة: $pUnit", style: arabicStyle),
                    ],
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // الجدول الديناميكي الموزع
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              children: [
                // سطر الأشهر
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: months.map((m) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Center(child: pw.Text(m, style: arabicStyle)),
                  )).toList(),
                ),
                // سطر الحالات المكتشفة
                pw.TableRow(
                  children: months.map((m) {
                    // جلب الحالات المطابقة للشهر من تفاصيل قاعدة البيانات الخاصة بالشخص
                    String statusValue = "-";
                    for (var p in people) {
                      if (p["month"] == m) {
                        statusValue = p["status"]?.toString() ?? "-";
                        break;
                      }
                    }
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(child: pw.Text(statusValue, style: arabicStyle)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 40),
          // التواقيع السفلية الموزعة بالزوايا
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("توقيع مدير القسم: ....................", style: arabicStyle),
              pw.Text("توقيع الاعتماد: ....................", style: arabicStyle),
            ],
          ),
          if (footerText.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Center(child: pw.Text(footerText, style: arabicStyle)),
          ]
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/status_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    
    await OpenFile.open(file.path);
    return file.path;
  }
}
