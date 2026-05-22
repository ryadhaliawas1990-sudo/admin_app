import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  String fromMonth = "يناير";
  String toMonth = "ديسمبر";

  final TextEditingController searchController = TextEditingController();

  String importYear = "2026";
  String importMonth = "1";

  bool isImporting = false;

  final List<String> years = [
    "2019","2020","2021","2022","2023","2024",
    "2025","2026","2027","2028","2029","2030"
  ];

  final List<String> months = [
    "يناير","فبراير","مارس","أبريل","مايو","يونيو",
    "يوليو","أغسطس","سبتمبر","أكتوبر","نوفمبر","ديسمبر"
  ];

  final Map<String, int> monthNumbers = {
    "يناير": 1,"فبراير": 2,"مارس": 3,"أبريل": 4,"مايو": 5,"يونيو": 6,
    "يوليو": 7,"أغسطس": 8,"سبتمبر": 9,"أكتوبر": 10,"نوفمبر": 11,"ديسمبر": 12,
  };

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

              // =========================
              // الاستيراد
              // =========================
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
                              items: years.map((y) =>
                                DropdownMenuItem(value: y, child: Text(y))
                              ).toList(),
                              onChanged: (v) => setState(() => importYear = v!),
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
                              items: List.generate(
                                12,
                                (i) => (i + 1).toString(),
                              ).map((m) =>
                                DropdownMenuItem(value: m, child: Text("شهر $m"))
                              ).toList(),
                              onChanged: (v) => setState(() => importMonth = v!),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      isImporting
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                              ),
                              onPressed: _pickAndImportExcel,
                              icon: const Icon(Icons.upload_file, color: Colors.white),
                              label: const Text("رفع ملف Excel",
                                  style: TextStyle(color: Colors.white)),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // الأشهر المستوردة (NEW)
              // =========================
              _buildSectionTitle("📅 الأشهر المستوردة"),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: DBHelper.getImportedMonths(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final monthsData = snapshot.data!;

                  if (monthsData.isEmpty) {
                    return const Text("لا توجد أشهر مستوردة");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: monthsData.length,
                    itemBuilder: (context, i) {

                      final item = monthsData[i];

                      return Card(
                        child: ListTile(
                          title: Text("شهر ${item['month']} / ${item['year']}"),
                          subtitle: Text("تاريخ: ${item['imported_at']}"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await DBHelper.deleteImportedMonth(
                                    item['month'],
                                    item['year'],
                                  );

                                  await DBHelper.deleteMonth(
                                    item['month'],
                                    item['year'],
                                  );

                                  setState(() {});
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.blue),
                                onPressed: () async {

                                  await DBHelper.deleteMonth(
                                    item['month'],
                                    item['year'],
                                  );

                                  await DBHelper.deleteImportedMonth(
                                    item['month'],
                                    item['year'],
                                  );

                                  setState(() {});

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("يمكن إعادة استيراد الشهر الآن"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 25),

              // =========================
              // التقرير
              // =========================
              _buildSectionTitle("📊 إنشاء تقرير PDF"),

              DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(
                  labelText: "السنة",
                  border: OutlineInputBorder(),
                ),
                items: years.map((y) =>
                  DropdownMenuItem(value: y, child: Text(y))
                ).toList(),
                onChanged: (v) => setState(() => selectedYear = v!),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "بحث بالرقم أو الاسم",
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
                      decoration: const InputDecoration(
                        labelText: "من شهر",
                        border: OutlineInputBorder(),
                      ),
                      items: months.map((m) =>
                        DropdownMenuItem(value: m, child: Text(m))
                      ).toList(),
                      onChanged: (v) => setState(() => fromMonth = v!),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: toMonth,
                      decoration: const InputDecoration(
                        labelText: "إلى شهر",
                        border: OutlineInputBorder(),
                      ),
                      items: months.map((m) =>
                        DropdownMenuItem(value: m, child: Text(m))
                      ).toList(),
                      onChanged: (v) => setState(() => toMonth = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _generateFilteredReport,
                child: const Text("إنشاء التقرير PDF"),
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

      if (result == null || result.files.single.path == null) return;

      setState(() => isImporting = true);

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first];

      List<Map<String, dynamic>> rows = [];

      for (int i = 1; i < sheet!.rows.length; i++) {
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

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    } finally {
      if (mounted) setState(() => isImporting = false);
    }
  }

  // =========================
  // REPORT
  // =========================
  Future<void> _generateFilteredReport() async {
    final db = await DBHelper.database;

    final records = await db.query(
      'timeline',
      where: 'year = ?',
      whereArgs: [selectedYear],
    );

    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: ["الرقم","الاسم","الرتبة","الوحدة","الحالة","الشهر","السنة"],
          data: records.map((e) => [
            e['number'],
            e['name'],
            e['rank'],
            e['unit'],
            e['status'],
            e['month'],
            e['year'],
          ]).toList(),
          headerStyle: pw.TextStyle(font: font),
          cellStyle: pw.TextStyle(font: font),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/hr_report.pdf");

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
