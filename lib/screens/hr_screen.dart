import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db/db_helper.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  String selectedYear = "2026";
  String fromMonth = "يناير";
  String toMonth = "ديسمبر";
  final TextEditingController searchController = TextEditingController();

  // السنوات تبدأ من 2019 وتستمر ديناميكياً
  final List<String> years = ["2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"];
  
  final List<String> months = [
    "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
    "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
  ];

  final Map<String, int> monthNumbers = {
    "يناير": 1, "فبراير": 2, "مارس": 3, "أبريل": 4, "مايو": 5, "يونيو": 6,
    "يوليو": 7, "أغسطس": 8, "سبتمبر": 9, "أكتوبر": 10, "نوفمبر": 11, "ديسمبر": 12
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الموارد البشرية - المباينة الدورية"), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: "السنة", border: OutlineInputBorder()),
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (val) => setState(() => selectedYear = val!),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "رقم الفرد العسكري أو الاسم",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: fromMonth,
                      decoration: const InputDecoration(labelText: "من شهر", border: OutlineInputBorder()),
                      items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => fromMonth = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: toMonth,
                      decoration: const InputDecoration(labelText: "إلى شهر", border: OutlineInputBorder()),
                      items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => toMonth = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue.shade700,
                ),
                onPressed: _generateFilteredReport,
                child: const Text(
                  "عرض المباينة وتوليد PDF",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateFilteredReport() async {
    int startMonth = monthNumbers[fromMonth] ?? 1;
    int endMonth = monthNumbers[toMonth] ?? 12;
    String query = searchController.text.trim();

    // جلب البيانات الخام من قاعدة البيانات الحقيقية لقراءة نطاق الأشهر
    final db = await DBHelper.database;
    List<Map<String, dynamic>> allRecords;

    if (query.isEmpty) {
      allRecords = await db.query('timeline', where: 'year = ?', whereArgs: [selectedYear]);
    } else {
      allRecords = await db.query(
        'timeline',
        where: 'year = ? AND (number = ? OR name LIKE ?)',
        whereArgs: [selectedYear, query, '%$query%'],
      );
    }

    // فلترة السجلات يدوياً وبأمان بناءً على النطاق الرقمي للأشهر المخزنة كنصوص
    List<Map<String, dynamic>> filteredRecords = allRecords.where((row) {
      int rowMonth = int.tryParse(row['month']?.toString() ?? '0') ?? 0;
      return rowMonth >= startMonth && rowMonth <= endMonth;
    }).toList();

    if (filteredRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لم يتم العثور على أي سجلات حالة في هذه الفترة المحددة")),
      );
      return;
    }

    // بناء ملف الـ PDF بمحاذاة عربية وبدون مربعات
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: pw.Font.courier()),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              cross: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "تقرير مباينة سجل الحالة الدوري",
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("الفترة الزمنية: من $fromMonth إلى $toMonth لعام $selectedYear"),
                pw.Text("البحث المستهدف: ${query.isEmpty ? "كل الأفراد" : query}"),
                pw.Divider(),
                pw.SizedBox(height: 15),
                pw.TableHelper.fromTextArray(
                  headers: ["الرقم العسكري", "الاسم", "الرتبة", "القوة/الوحدة", "الحالة", "الشهر/السنة"],
                  data: filteredRecords.map((r) => [
                    r['number'] ?? '',
                    r['name'] ?? '',
                    r['rank'] ?? '',
                    r['unit'] ?? '',
                    r['status'] ?? '',
                    "${r['month']}/${r['year']}",
                  ]).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerRight,
                ),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/filtered_report.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
