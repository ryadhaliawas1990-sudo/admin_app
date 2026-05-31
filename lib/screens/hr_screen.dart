import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import '../db/db_helper.dart';
import '../services/excel_to_db_service.dart';
import 'follow_up_screen.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});
  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  String importYear = "2026", importMonth = "1", fromYear = "2026", toYear = "2026", fromMonth = "1", toMonth = "12";
  bool isImporting = false;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = []; // قائمة تخزين نتائج البحث
  final List<String> years = List.generate(12, (i) => (2019 + i).toString());
  final List<String> months = List.generate(12, (i) => (i + 1).toString());

  // دالة البحث المباشر
  Future<void> _performSearch(String query) async {
    final db = await DBHelper.database;
    final results = await db.rawQuery('''
      SELECT * FROM timeline
      WHERE (number LIKE ? OR name LIKE ? OR rank LIKE ? OR unit LIKE ? OR status LIKE ?)
      ORDER BY CAST(year AS INTEGER) ASC, CAST(month AS INTEGER) ASC
    ''', ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%']);
    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الموارد البشرية"), centerTitle: true, actions: [
        IconButton(icon: const Icon(Icons.list_alt), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowUpScreen())))
      ]),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(labelText: "بحث بالاسم أو الرقم...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                onChanged: _performSearch, // البحث لحظي عند الكتابة
              ),
              Expanded(
                child: ListView(
                  children: [
                    // عرض النتائج إذا وجدت
                    ..._searchResults.map((r) => ListTile(
                      title: Text("${r['name']} - ${r['number']}"),
                      subtitle: Text("الوحدة: ${r['unit']} | الحالة: ${r['status']}"),
                    )),
                    const Divider(),
                    _buildSectionTitle("📥 استيراد كشوفات الأفراد"),
                    _buildImportCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle("📊 إنشاء تقرير (كتلي)"),
                    _buildReportFilters(),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _generateFilteredReport, child: const Text("تصدير التقرير (Excel)")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- الدوال السابقة (الاستيراد + التقارير + العرض) ---
  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)));

  Widget _buildImportCard() {
    return Card(color: Colors.blue.shade50, child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(value: importYear, decoration: const InputDecoration(labelText: "السنة"), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setState(() => importYear = v!))),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<String>(value: importMonth, decoration: const InputDecoration(labelText: "الشهر"), items: months.map((m) => DropdownMenuItem(value: m, child: Text("شهر $m"))).toList(), onChanged: (v) => setState(() => importMonth = v!))),
      ]),
      const SizedBox(height: 15),
      isImporting ? const CircularProgressIndicator() : ElevatedButton.icon(onPressed: _pickAndImportExcel, icon: const Icon(Icons.upload_file), label: const Text("رفع ملف Excel")),
    ])));
  }

  Future<void> _pickAndImportExcel() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
    if (result == null) return;
    setState(() => isImporting = true);
    try {
      final bytes = await File(result.files.single.path!).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first]!;
      List<Map<String, dynamic>> batch = [];
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        batch.add({
          "number": row[1]?.value?.toString() ?? "", "rank": row[2]?.value?.toString() ?? "",
          "name": row[3]?.value?.toString() ?? "", "unit": row[4]?.value?.toString() ?? "",
          "status": row[5]?.value?.toString() ?? "", "month": importMonth, "year": importYear,
        });
        if (batch.length >= 200) { await ExcelToDbService.import(batch, importMonth, importYear); batch.clear(); }
      }
      if (batch.isNotEmpty) await ExcelToDbService.import(batch, importMonth, importYear);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم الاستيراد بنجاح")));
    } catch (e) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e"))); }
    setState(() => isImporting = false);
  }

  Widget _buildReportFilters() {
    return Column(children: [
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(value: fromYear, decoration: const InputDecoration(labelText: "من سنة"), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setState(() => fromYear = v!))),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<String>(value: toYear, decoration: const InputDecoration(labelText: "إلى سنة"), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setState(() => toYear = v!))),
      ]),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(value: fromMonth, decoration: const InputDecoration(labelText: "من شهر"), items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => fromMonth = v!))),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<String>(value: toMonth, decoration: const InputDecoration(labelText: "إلى شهر"), items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => toMonth = v!))),
      ]),
    ]);
  }

  Future<void> _generateFilteredReport() async {
    final db = await DBHelper.database;
    final search = searchController.text.trim();
    final records = await db.rawQuery('''
      SELECT * FROM timeline
      WHERE (CAST(year AS INTEGER) BETWEEN ? AND ?)
      AND (CAST(month AS INTEGER) BETWEEN ? AND ?)
      AND (number LIKE ? OR name LIKE ? OR rank LIKE ? OR unit LIKE ? OR status LIKE ?)
    ''', [fromYear, toYear, fromMonth, toMonth, '%$search%', '%$search%', '%$search%', '%$search%', '%$search%']);
    if (records.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا توجد بيانات"))); return; }
    // (بقية كود التصدير كما هو...)
    final excel = Excel.createExcel();
    final sheet = excel['HR Report'];
    Map<String, Map<String, dynamic>> grouped = {};
    for (final r in records) {
      final key = r['number'].toString();
      grouped.putIfAbsent(key, () => {"number": r['number'], "rank": r['rank'], "name": r['name'], "unit": r['unit'], "timeline": []});
      grouped[key]!["timeline"].add(r);
    }
    for (final p in grouped.values) {
        List<dynamic> timeline = p['timeline'];
        sheet.appendRow([TextCellValue(p['number'].toString()), TextCellValue(p['rank'].toString()), TextCellValue(p['name'].toString()), ...timeline.map((c) => TextCellValue("${c['month']}/${c['year']}"))]);
    }
    final file = File("${(await getApplicationDocumentsDirectory()).path}/report.xlsx");
    await file.writeAsBytes(excel.encode()!);
    OpenFile.open(file.path);
  }
}
