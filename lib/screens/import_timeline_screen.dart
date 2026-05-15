import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:io';
import 'package:excel/excel.dart';

import '../db/db_helper.dart';

class ImportTimelineScreen extends StatefulWidget {
  const ImportTimelineScreen({super.key});

  @override
  State<ImportTimelineScreen> createState() => _ImportTimelineScreenState();
}

class _ImportTimelineScreenState extends State<ImportTimelineScreen> {

  String selectedMonth = "يناير";
  String selectedYear = "2026";

  bool loading = false;

  final months = [
    "يناير","فبراير","مارس","أبريل","مايو","يونيو",
    "يوليو","أغسطس","سبتمبر","أكتوبر","نوفمبر","ديسمبر"
  ];

  final years = [
    "2024","2025","2026","2027","2028"
  ];

  Future<void> importFile() async {

    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (file == null) return;

    setState(() => loading = true);

    final bytes = File(file.files.single.path!).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables.values.first;

    for (var row in sheet.rows.skip(1)) {

      final number = row[0]?.value?.toString() ?? "";
      final name = row[1]?.value?.toString() ?? "";
      final rank = row[2]?.value?.toString() ?? "";
      final unit = row[3]?.value?.toString() ?? "";
      final status = row[4]?.value?.toString() ?? "";

      if (number.isEmpty) continue;

      await DBHelper.insertTimeline({
        "number": number,
        "name": name,
        "rank": rank,
        "unit": unit,
        "status": status,
        "month": selectedMonth,
        "year": selectedYear,
      });
    }

    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم استيراد الملف بنجاح"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("استيراد سجل زمني"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // الشهر
            DropdownButtonFormField(
              value: selectedMonth,
              items: months.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m),
                );
              }).toList(),
              onChanged: (v) {
                setState(() => selectedMonth = v.toString());
              },
              decoration: const InputDecoration(
                labelText: "الشهر",
              ),
            ),

            const SizedBox(height: 10),

            // السنة
            DropdownButtonFormField(
              value: selectedYear,
              items: years.map((y) {
                return DropdownMenuItem(
                  value: y,
                  child: Text(y),
                );
              }).toList(),
              onChanged: (v) {
                setState(() => selectedYear = v.toString());
              },
              decoration: const InputDecoration(
                labelText: "السنة",
              ),
            ),

            const SizedBox(height: 20),

            // زر الاستيراد
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : importFile,
                child: Text(
                  loading ? "جاري الاستيراد..." : "اختيار ملف Excel",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
