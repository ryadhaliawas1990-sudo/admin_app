import 'package:flutter/material.dart';
import '../db/db_helper.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

// ✅ مهم: حل تعارض Border
import 'package:excel/excel.dart' as ex;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int totalPeople = 0;
  int totalRecords = 0;
  int totalYears = 0;

  Map<String, int> statusCount = {};

  bool loading = true;

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  String latestMonth = "";
  String latestYear = "";

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  // =========================
  // تحميل الإحصائيات
  // =========================
  Future<void> loadStats() async {
    try {
      final db = await DBHelper.database;

      final people = await db.rawQuery('''
        SELECT COUNT(DISTINCT number) as count
        FROM timeline
      ''');

      final records = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM timeline
      ''');

      final years = await db.rawQuery('''
        SELECT COUNT(DISTINCT year) as count
        FROM timeline
      ''');

      // آخر شهر
      final latest = await db.rawQuery('''
        SELECT year, month
        FROM timeline
        ORDER BY CAST(year AS INTEGER) DESC,
                 CAST(month AS INTEGER) DESC
        LIMIT 1
      ''');

      if (latest.isNotEmpty) {
        latestYear = latest.first['year'].toString();
        latestMonth = latest.first['month'].toString();
      }

      // توزيع الحالات (آخر شهر فقط)
      final statuses = await db.rawQuery('''
        SELECT status, COUNT(*) as count
        FROM timeline
        WHERE year = ?
          AND month = ?
          AND status IS NOT NULL
          AND TRIM(status) != ''
          AND status != '-'
        GROUP BY status
        ORDER BY count DESC
      ''', [latestYear, latestMonth]);

      Map<String, int> map = {};

      for (var s in statuses) {
        final key = s['status'].toString().trim();
        final value = int.tryParse(s['count'].toString()) ?? 0;

        if (key.isNotEmpty) {
          map[key] = value;
        }
      }

      if (!mounted) return;

      setState(() {
        totalPeople = int.tryParse(people.first['count'].toString()) ?? 0;
        totalRecords = int.tryParse(records.first['count'].toString()) ?? 0;
        totalYears = int.tryParse(years.first['count'].toString()) ?? 0;

        statusCount = map;
        loading = false;
      });

    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => loading = false);
    }
  }

  // =========================
  // البحث
  // =========================
  Future<void> searchPeople(String value) async {
    final db = await DBHelper.database;

    if (value.trim().isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final data = await db.query(
      'timeline',
      where: 'number LIKE ? OR name LIKE ?',
      whereArgs: ['%$value%', '%$value%'],
      limit: 30,
    );

    setState(() => searchResults = data);
  }

  // =========================
  // تصدير Excel للحالة
  // =========================
  Future<void> exportStatusExcel(String status) async {
    final db = await DBHelper.database;

    final data = await db.query(
      'timeline',
      where: '''
        status = ?
        AND year = ?
        AND month = ?
      ''',
      whereArgs: [status, latestYear, latestMonth],
    );

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا توجد بيانات")),
      );
      return;
    }

    final excel = ex.Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      ex.TextCellValue("الرقم"),
      ex.TextCellValue("الاسم"),
      ex.TextCellValue("الرتبة"),
      ex.TextCellValue("الوحدة"),
      ex.TextCellValue("الحالة"),
      ex.TextCellValue("الشهر"),
      ex.TextCellValue("السنة"),
    ]);

    for (var row in data) {
      sheet.appendRow([
        ex.TextCellValue(row['number']?.toString() ?? ''),
        ex.TextCellValue(row['name']?.toString() ?? ''),
        ex.TextCellValue(row['rank']?.toString() ?? ''),
        ex.TextCellValue(row['unit']?.toString() ?? ''),
        ex.TextCellValue(row['status']?.toString() ?? ''),
        ex.TextCellValue(row['month']?.toString() ?? ''),
        ex.TextCellValue(row['year']?.toString() ?? ''),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/status_$status.xlsx");

    await file.writeAsBytes(excel.encode()!);

    await OpenFile.open(file.path);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم تصدير ملف: $status")),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("لوحة التحكم")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(child: _card("الأفراد", totalPeople)),
                      const SizedBox(width: 10),
                      Expanded(child: _card("السجلات", totalRecords)),
                    ],
                  ),

                  const SizedBox(height: 10),
                  _card("السنوات", totalYears),

                  const SizedBox(height: 15),

                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: "بحث",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: searchPeople,
                  ),

                  const SizedBox(height: 10),

                  if (searchResults.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (_, i) {
                          final item = searchResults[i];
                          return ListTile(
                            title: Text(item['name'] ?? ''),
                            subtitle: Text(item['number'] ?? ''),
                            trailing: Text(item['status'] ?? ''),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "الحالات (آخر شهر: $latestMonth / $latestYear)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: GridView.builder(
                      itemCount: statusCount.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                      ),
                      itemBuilder: (_, i) {
                        final key = statusCount.keys.elementAt(i);
                        final value = statusCount[key]!;

                        return InkWell(
                          onTap: () => exportStatusExcel(key),
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(value.toString()),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(String title, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
