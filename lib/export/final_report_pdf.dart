import 'dart:io';
import 'package:flutter/services.dart'; // حاسمة لجلب الخط من الـ assets
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

    // 1. تحميل خط القاهرة العربي من الـ assets وتفعيله كمحرك نصوص للـ PDF
    final ByteData fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final pw.Font arabicFont = pw.Font.ttf(fontData);

    // 2. إنشاء نمط نصوص موحد يدعم العربية والاتجاه من اليمين إلى اليسار
    final pw.TextStyle arabicStyle = pw.TextStyle(
      font: arabicFont,
      fontSize: 11,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        // تفعيل اتجاه الكتابة من اليمين إلى اليسار للصفحة بأكملها
        textDirection: pw.TextDirection.rtl, 
        build: (context) {

          return [

            // 🟢 العنوان الرئيسي للتقرير
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    "تقرير المباينة النهائي",
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  if (headerText.isNotEmpty) ...[
                    pw.SizedBox(height: 5),
                    pw.Text(
                      headerText,
                      style: pw.TextStyle(font: arabicFont, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: 15),

            // 🧾 جدول البيانات المحصن والمعكوس الاتجاه
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(40),  // الرقم
                1: const pw.FixedColumnWidth(120), // الاسم
                2: const pw.FixedColumnWidth(60),  // الرتبة
              },
              children: [

                // ترويسة الجدول (العناوين) مرتبة من اليمين لليسار
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text("الرقم", style: arabicStyle))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text("الاسم", style: arabicStyle))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text("الرتبة", style: arabicStyle))),
                    ...months.map((m) => pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(child: pw.Text(m, style: arabicStyle)),
                        )),
                  ],
                ),

                // بناء صفوف الحالات والأشهر ديناميكياً
                ...people.map((p) {
                  final monthsMap = (p["months"] ?? {}) as Map<String, dynamic>;

                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(p["number"] ?? "", style: arabicStyle))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Container(alignment: pw.Alignment.centerRight, child: pw.Text(p["name"] ?? "", style: arabicStyle))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text(p["rank"] ?? "", style: arabicStyle))),

                      ...months.map((m) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Text(
                              (monthsMap[m] ?? "-").toString(),
                              style: arabicStyle,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 25),

            // ✍️ قطاع التواقيع والإعتماد الإداري
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("مدير القسم", style: arabicStyle),
                pw.Text("المراجعة", style: arabicStyle),
                pw.Text("الاعتماد", style: arabicStyle),
              ],
            ),

            if (footerText.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 5),
              pw.Center(child: pw.Text(footerText, style: arabicStyle)),
            ],
          ];
        },
      ),
    );

    // 💾 حفظ الملف في ذاكرة الجهاز المؤقتة بأمان واحترافية
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());
    final path = file.path;

    // 📂 الفتح التلقائي للمستند بعد التصدير
    if (autoOpen) {
      await OpenFile.open(path);
    }

    // 📤 تفعيل نظام المشاركة عبر التطبيقات الأخرى
    if (shareFile) {
      await Share.shareXFiles([XFile(path)]);
    }

    return path;
  }
}
