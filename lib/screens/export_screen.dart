import 'package:flutter/material.dart';
import '../export/final_report_excel.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {

  String? selectedStatus;
  String? selectedUnit;
  String? selectedRank;

  bool loading = false;
  String message = '';

  final List<String> statuses = ['نشط', 'إجازة', 'منقطع'];
  final List<String> units = ['الوحدة 1', 'الوحدة 2'];
  final List<String> ranks = ['جندي', 'رقيب', 'ضابط'];

  Future<void> export() async {
    setState(() {
      loading = true;
      message = 'جاري التصدير...';
    });

    try {

      // =========================
      // Excel الجديد (مؤقت ببيانات تجريبية)
      // =========================
      await FinalReportExcel.export(
        months: ['1', '2', '3'],
        people: [
          {
            "number": "123",
            "name": "Test User",
            "rank": selectedRank ?? "-",
            "unit": selectedUnit ?? "-",
            "status": selectedStatus ?? "-",
            "month": "1",
          }
        ],
      );

      setState(() {
        message = 'تم التصدير بنجاح ✔';
      });

    } catch (e) {
      setState(() {
        message = 'حدث خطأ أثناء التصدير ❌';
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصدير Excel'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🟢 الحالة
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الحالة',
                border: OutlineInputBorder(),
              ),
              items: statuses.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => selectedStatus = v,
            ),

            const SizedBox(height: 10),

            // 🟢 الوحدة
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الوحدة',
                border: OutlineInputBorder(),
              ),
              items: units.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => selectedUnit = v,
            ),

            const SizedBox(height: 10),

            // 🟢 الرتبة
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الرتبة',
                border: OutlineInputBorder(),
              ),
              items: ranks.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => selectedRank = v,
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: export,
                    child: const Text('تصدير Excel'),
                  ),

            const SizedBox(height: 20),

            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
