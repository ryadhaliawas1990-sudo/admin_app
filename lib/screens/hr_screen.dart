import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart'; // حقن مكتبة الإكسل لمعالجة الملفات برمجياً

import '../db/db_helper.dart';
import '../core/excel_reader.dart';
import '../services/excel_to_db_service.dart';

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

  String importYear = "2026";
  String importMonth = "1";
  bool isImporting = false;

  final List<String> years = ["2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"];
  final List<String> months = ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"];

  final Map<String, int> monthNumbers = {
    "يناير": 1, "فبراير": 2, "مارس": 3, "أبريل": 4, "مايو": 5, "يونيو": 6,
    "يوليو": 7, "أغسطس": 8, "سبتمبر": 9, "أكتوبر": 10, "نوفمبر": 11, "ديسمبر": 12
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الموارد البشرية والأفراد"), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // 📥 استيراد القوة البشرية
              _buildSectionTitle("📥 استيراد كشوفات الأفراد الدورية (Excel)"),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: importYear,
                              decoration: const InputDecoration(labelText: "سنة الكشف", border: OutlineInputBorder()),
                              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                              onChanged: (val) => setState(() => importYear = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: importMonth,
                              decoration: const InputDecoration(labelText: "شهر الكشف (رقم)", border: OutlineInputBorder()),
                              items: List.generate(12, (i) => (i + 1).toString()).map((m) => DropdownMenuItem(value: m, child: Text("شهر $m"))).toList(),
                              onChanged: (val) => setState(() => importMonth = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      isImporting
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                            onPressed: _pickAndImportExcel,
                            icon: const Icon(Icons.file_upload, color: Colors.white),
                            label: const Text("رفع ملف كشف الأفراد", style: TextStyle(color: Colors.white)),
                          ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 2),

              // 📊 المباينة الدورية للأفراد
              _buildSectionTitle("📊 مباينة سجل الحالة (من شهر إلى شهر)"),
              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: "سنة البحث", border: OutlineInputBorder()),
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                onChanged: (val) => setState(() => selectedYear = val!),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(labelText: "رقم الفرد أو الاسم لفرز حالته", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
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
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.blue.shade700),
                onPressed: _generateFilteredReport,
                child: const Text("عرض المباينة وتوليد PDF للأفراد", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo)),
    );
  }

  // الدالة المصححة بالكامل لتتوافق مع دالة ملف excel_reader.dart الحقيقية
  Future<void> _pickAndImportExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
      if (result != null && result.files.single.path != null) {
        setState(() => isImporting = true);
        var bytes = File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        // جلب أول صفحة (Sheet) من الملف تلقائياً
        String firstSheetName = excel.tables.keys.first;
        var sheet = excel.tables[firstSheetName];

        if (sheet == null) throw Exception("لا توجد صفحات داخل ملف الإكسل");

        // استدعاء الدالة الصحيحة والموجودة فعلياً في كودك: readData
        List<Map<String, dynamic>> excelData = ExcelReader.readData(sheet);

        if (excelData.isEmpty) throw Exception("الملف فارغ أو غير مدعوم التنسيق");

        await ExcelToDbService.import(excelData, importMonth, importYear);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("تم استيراد بيانات الأفراد بنجاح")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("خطأ: ${e.toString()}")));
    } finally { setState(() => isImporting = false); }
  }

  Future<void> _generateFilteredReport() async {
    int startMonth = monthNumbers[fromMonth] ?? 1;
    int endMonth = monthNumbers[toMonth] ?? 12;
    String query = searchController.text.trim();

    final db = await DBHelper.database;
    List<Map<String, dynamic>> allRecords;

    if (query.isEmpty) {
      allRecords = await db.query('timeline', where: 'year = ?', whereArgs: [selectedYear]);
    } else {
      allRecords = await db.query('timeline', where: 'year = ? AND (number = ? OR name LIKE ?)', whereArgs: [selectedYear, query, '%$query%']);
    }

    List<Map<String, dynamic>> filteredRecords = allRecords.where((row) {
      int rowMonth = int.tryParse(row['month']?.toString() ?? '0') ?? 0;
      return rowMonth >= startMonth && rowMonth <= endMonth;
    }).toList();

    if (filteredRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا توجد سجلات أفراد لهذه الفترة")));
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: pw.Font.courier()),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text("تقرير مباينة سجل الحالة الدوري للأفراد", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 15),
              pw.TableHelper.fromTextArray(
                headers: ["الرقم العسكري", "الاسم", "الرتبة", "القوة/الوحدة", "الحالة", "الشهر/السنة"],
                data: filteredRecords.map((r) => [r['number'] ?? '', r['name'] ?? '', r['rank'] ?? '', r['unit'] ?? '', r['status'] ?? '', "${r['month']}/${r['year']}"]).toList(),
                cellAlignment: pw.Alignment.centerRight,
              ),
            ],
          ),
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/filtered_hr_report.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
