import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import '../db/db_helper.dart';
import '../services/excel_to_db_service.dart';
import 'follow_up_screen.dart'; // استيراد شاشة المتابعة الجديدة

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});
  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  String importYear = "2026";
  String importMonth = "1";
  String fromYear = "2026";
  String toYear = "2026";
  String fromMonth = "1";
  String toMonth = "12";
  bool isImporting = false;

  final List<String> years = List.generate(12, (i) => (2019 + i).toString());
  final List<String> months = List.generate(12, (i) => (i + 1).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الموارد البشرية"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "سجل المتابعة والملاحظات",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowUpScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionTitle("📥 استيراد كشوفات الأفراد"),
            _buildImportCard(),
            const SizedBox(height: 10),
            _buildImportedMonthsList(),
            const SizedBox(height: 25),
            _buildSectionTitle("📊 إنشاء تقرير كتلي"),
            _buildReportFilters(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _generateFilteredReport,
              icon: const Icon(Icons.download),
              label: const Text("تصدير التقرير (Excel)"),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildImportedMonthsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DBHelper.getImportedMonths(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        return Column(children: snapshot.data!.map((m) => ListTile(
          title: Text("شهر ${m['month']} - ${m['year']} (${m['total']} سجل)"),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
            await DBHelper.deleteMonth(m['month'].toString(), m['year'].toString());
            setState(() {});
          }),
        )).toList());
      },
    );
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

  Future<void> _pickAndImportExcel() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
    if (result == null) return;
    setState(() => isImporting = true);
    final bytes = await File(result.files.single.path!).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;
    List<Map<String, dynamic>> rows = [];
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      rows.add({
        "number": row[1]?.value?.toString() ?? "", "rank": row[2]?.value?.toString() ?? "",
        "name": row[3]?.value?.toString() ?? "", "unit": row[4]?.value?.toString() ?? "",
        "status": row[5]?.value?.toString() ?? "", "month": importMonth, "year": importYear,
      });
    }
    await ExcelToDbService.import(rows, importMonth, importYear);
    setState(() { isImporting = false; });
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم الاستيراد بنجاح")));
  }

  Future<void> _generateFilteredReport() async {
    final records = await DBHelper.getAllTimeline(); // أو استخدم استعلام مخصص كما في كودك
    if (records.isEmpty) { if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("لا توجد بيانات"))); return; }
    
    final excel = Excel.createExcel();
    final sheet = excel['HR Report'];
    Map<String, Map<String, dynamic>> grouped = {};
    for (final r in records) {
      final key = r['number'].toString();
      grouped.putIfAbsent(key, () => {"info": r, "timeline": []});
      grouped[key]!["timeline"].add(r);
    }
    for (final p in grouped.values) {
      final info = p['info'];
      sheet.appendRow([TextCellValue("الرقم"), TextCellValue(info['number'].toString())]);
      sheet.appendRow([TextCellValue("الرتبة"), TextCellValue(info['rank'].toString())]);
      sheet.appendRow([TextCellValue("الاسم"), TextCellValue(info['name'].toString())]);
      sheet.appendRow([TextCellValue("التاريخ"), ...p['timeline'].map((c) => TextCellValue("${c['month']}/${c['year']}"))]);
      sheet.appendRow([TextCellValue("الحالة"), ...p['timeline'].map((c) => TextCellValue(c['status'].toString()))]);
      sheet.appendRow([TextCellValue("")]);
    }
    final file = File("${(await getApplicationDocumentsDirectory()).path}/hr_report.xlsx");
    await file.writeAsBytes(excel.encode()!);
    if(mounted) OpenFile.open(file.path);
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)));
}
