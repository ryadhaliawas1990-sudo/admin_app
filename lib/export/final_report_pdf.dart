import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class FinalReportPdf {

  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String headerText = '',
    String footerText = '',
    bool autoOpen = true,
    bool shareFile = false,
  }) async {

    final pdf = pw.Document();

    // 🔬 الحماية الحرجة: جلب بايتات الخط العربي وإجبار النظام على استخدامها في كل النصوص
    final ByteData fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final pw.Font arabicFont = pw.Font.ttf(fontData);

    // تجهيز التنسيقات الموحدة للخطوط
    final pw.TextStyle titleStyle = pw.TextStyle(font: arabicFont, fontSize: 16, fontWeight: pw.FontWeight.bold);
    final pw.TextStyle subTitleStyle = pw.TextStyle(font: arabicFont, fontSize: 11, fontWeight: pw.FontWeight.normal);
    final pw.TextStyle tableHeaderStyle = pw.TextStyle(font: arabicFont, fontSize: 11, fontWeight: pw.FontWeight.bold);
    final pw.TextStyle tableBodyStyle = pw.TextStyle(font: arabicFont, fontSize: 10, fontWeight: pw.FontWeight.normal);

    // 📐 ميزة التكيف الديناميكي: إذا زاد عدد الأشهر عن 5 أشهُر، تقلب الصفحة تلقائياً إلى العرض (Landscape)
    PdfPageFormat dynamicFormat = PdfPageFormat.a4.portrait;
    if (months.length > 5) {
      dynamicFormat = PdfPageFormat.a4.landscape;
    }

    // نأخذ بيانات المذكور الأول (بما أن التقرير مخصص لسجل حالة فرد محدد)
    final Map<String, dynamic> person = people.isNotEmpty ? people.first : {};
    final String pNumber = person["number"]?.toString() ?? "-";
    final String pName = person["name"]?.toString() ?? "-";
    final String pRank = person["rank"]?.toString() ?? "-";
    final Map<dynamic, dynamic> monthsMap = (person["months"] ?? {}) as Map<dynamic, dynamic>;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: dynamicFormat,
        textDirection: pw.TextDirection.rtl, // توجيه كامل المستند من اليمين لليسار
        build: (context) {
          return [

            // 1. ترويسة التقرير والنص اليدوي الأعلى
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text("تقرير سجل الحالة الدوري", style: titleStyle),
                  pw.SizedBox(height: 5),
                  if (headerText.isNotEmpty)
                    pw.Text(headerText, style: subTitleStyle, textAlign: pw.TextAlign.center),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // 2. قطاع البيانات الأساسية (خارج الجدول - يمين الصفحة)
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                padding: const pw.EdgeInsets.all(10),
              ),
              child: pw.Column(
                cross: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("الرقم العسكري: $pNumber", style: tableHeaderStyle),
                      pw.Text("الرتبة: $pRank", style: tableHeaderStyle),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text("الاسم الكامل: $pName", style: tableHeaderStyle),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // 3. الجدول الديناميكي المطور (الأشهر والحالات)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
              children: [
                
                // سطر العناوين (الأشهر المحددة)
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: months.map((m) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: pw.Center(child: pw.Text(m, style: tableHeaderStyle)),
                  )).toList(),
                ),

                // سطر البيانات (حالة المذكور تحت كل شهر)
                pw.TableRow(
                  children: months.map((m) {
                    // حماية من قيم null المسببة للخلل في الصورة
                    String statusValue = monthsMap[m]?.toString() ?? "-";
                    if (statusValue.trim().toLowerCase() == 'null' || statusValue.trim().isEmpty) {
                      statusValue = "-";
                    }
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: pw.Center(child: pw.Text(statusValue, style: tableBodyStyle)),
                    );
                  }).toList(),
                ),

              ],
            ),

            pw.SizedBox(height: 35),

            // 4. التواقيع الإدارية الموزعة بدقة متناهية في الزوايا السفلية
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("توقيع مدير القسم: ....................", style: subTitleStyle),
                pw.Text("توقيع المراجعة: ....................", style: subTitleStyle),
                pw.Text("توقيع الاعتماد: ....................", style: subTitleStyle),
              ],
            ),

            // 5. النص اليدوي السفلي إن وجد
            if (footerText.isNotEmpty) ...[
              pw.SizedBox(height: 25),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text(footerText, style: subTitleStyle)),
            ],

          ];
        },
      ),
    );

    // عملية الحفظ والتصدير والفتح الآمن
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/status_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    final path = file.path;

    if (autoOpen) {
      await OpenFile.open(path);
    }

    if (shareFile) {
      await Share.shareXFiles([XFile(path)]);
    }

    return path;
  }
}
