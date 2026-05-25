import 'package:flutter/material.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:excel/excel.dart';

import '../db/db_helper.dart';
import '../services/excel_to_db_service.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  String selectedYear = "2026";
  String importYear = "2026";
  String importMonth = "1";

  bool isImporting = false;

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  final List<String> years = [
    "2019","2020","2021","2022","2023","2024","2025",
    "2026","2027","2028","2029","2030"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الموارد البشرية"),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildSectionTitle("📥 استيراد كشوفات الأفراد"),

              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: importYear,
                              decoration: const InputDecoration(
                                labelText: "السنة",
                                border: OutlineInputBorder(),
                              ),
                              items: years.map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text(y),
                                );
                              }).toList(),
                              onChanged: (v) {
                                setState(() => importYear = v!);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: importMonth,
                              decoration: const InputDecoration(
                                labelText: "الشهر",
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(12, (i) => (i + 1).toString())
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text("شهر $m"),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => importMonth = v!);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      isImporting
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _pickAndImportExcel,
                              icon: const Icon(Icons.upload_file),
                              label: const Text("رفع ملف Excel"),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionTitle("📊 إنشاء تقرير"),

              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(
                  labelText: "السنة",
                  border: OutlineInputBorder(),
                ),
                items: years.map((y) {
                  return DropdownMenuItem(
                    value: y,
                    child: Text(y),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => selectedYear = v!);
                },
              ),

              const SizedBox(height: 15),

              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "بحث",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: searchPeople,
              ),

              const SizedBox(height: 10),

              if (searchResults.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, i) {
                    final item = searchResults[i];

                    return Card(
                      child: ListTile(
                        title: Text(
                          "${item['number']} - ${item['rank']} - ${item['name']}",
                        ),
                        subtitle: Text(
                          "الوحدة: ${item['unit']} | الحالة: ${item['status']}",
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _generateFilteredReport,
                child: const Text("إنشاء التقرير (Excel)"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  // =========================
  // IMPORT
  // =========================

  Future<void> _pickAndImportExcel() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) return;

      setState(() => isImporting = true);

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return;

      List<Map<String, dynamic>> rows = [];

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        rows.add({
          "number": row[1]?.value?.toString() ?? "",
          "rank": row[2]?.value?.toString() ?? "",
          "name": row[3]?.value?.toString() ?? "",
          "unit": row[4]?.value?.toString() ?? "",
          "status": row[5]?.value?.toString() ?? "",
          "month": importMonth,
          "year": importYear,
        });
      }

      await ExcelToDbService.import(rows, importMonth, importYear);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم الاستيراد بنجاح")),
      );
    } finally {
      if (mounted) {
        setState(() => isImporting = false);
      }
    }
  }

  // =========================
  // SEARCH
  // =========================

  Future<void> searchPeople(String value) async {
    final db = await DBHelper.database;

    if (value.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final data = await db.query(
      'timeline',
      where: '''
        number LIKE ?
        OR name LIKE ?
        OR rank LIKE ?
        OR unit LIKE ?
        OR status LIKE ?
      ''',
      whereArgs: List.filled(5, '%$value%'),
      limit: 50,
    );

    setState(() => searchResults = data);
  }

  // =========================
  // REPORT (EXCEL)
  // =========================

  Future<void> _generateFilteredReport() async {
    final db = await DBHelper.database;

    final search = searchController.text.trim();

    final records = await db.query(
      'timeline',
      where: '''
        year = ?
        AND (
          number LIKE ?
          OR name LIKE ?
          OR rank LIKE ?
          OR unit LIKE ?
          OR status LIKE ?
        )
      ''',
      whereArgs: [
        selectedYear,
        '%$search%',
        '%$search%',
        '%$search%',
        '%$search%',
        '%$search%',
      ],
      limit: 300,
    );

    if (records.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا توجد نتائج")),
      );

      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['HR Report'];

    sheet.appendRow([
      TextCellValue("الرقم"),
      TextCellValue("الرتبة"),
      TextCellValue("الاسم"),
      TextCellValue("الوحدة"),
      TextCellValue("الحالة"),
      TextCellValue("الشهر"),
      TextCellValue("السنة"),
    ]);

    for (var e in records) {
      sheet.appendRow([
        TextCellValue((e['number'] ?? '').toString()),
        TextCellValue((e['rank'] ?? '').toString()),
        TextCellValue((e['name'] ?? '').toString()),
        TextCellValue((e['unit'] ?? '').toString()),
        TextCellValue((e['status'] ?? '').toString()),
        TextCellValue((e['month'] ?? '').toString()),
        TextCellValue((e['year'] ?? '').toString()),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/hr_report.xlsx");

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception("فشل إنشاء Excel");
    }

    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}
