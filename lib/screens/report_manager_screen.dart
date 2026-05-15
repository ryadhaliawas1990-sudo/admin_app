import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../export/batch_timeline_pdf.dart';

class ReportManagerScreen extends StatefulWidget {
  const ReportManagerScreen({super.key});

  @override
  State<ReportManagerScreen> createState() => _ReportManagerScreenState();
}

class _ReportManagerScreenState extends State<ReportManagerScreen> {

  List<Map<String, dynamic>> allData = [];
  List<String> selectedNumbers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    final db = await DBHelper.database;

    final result = await db.rawQuery('''
      SELECT DISTINCT number, name, rank
      FROM timeline
    ''');

    setState(() {
      allData = result;
      loading = false;
    });
  }

  void toggleSelection(String number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else {
        selectedNumbers.add(number);
      }
    });
  }

  Future<void> generateReport() async {

    if (selectedNumbers.isEmpty) return;

    await BatchTimelinePdf.generate(
      numbers: selectedNumbers,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إنشاء التقرير الجماعي"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة التقارير"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: generateReport,
        child: const Icon(Icons.picture_as_pdf),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allData.length,
              itemBuilder: (context, index) {

                final item = allData[index];
                final number = item['number'] ?? '';

                final isSelected = selectedNumbers.contains(number);

                return Card(
                  child: ListTile(
                    title: Text(item['name'] ?? ''),
                    subtitle: Text("الرقم: $number | الرتبة: ${item['rank']}"),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => toggleSelection(number),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
