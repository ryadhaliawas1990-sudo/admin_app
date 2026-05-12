import 'package:flutter/material.dart';

import '../services/comparison_diff_service.dart';
import '../services/smart_report_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map<String, dynamic>? diff;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    final monthA = [
      {"number": "1", "name": "أحمد", "status": "نشط"},
      {"number": "2", "name": "محمد", "status": "نشط"},
      {"number": "3", "name": "خالد", "status": "غير نشط"},
    ];

    final monthB = [
      {"number": "1", "name": "أحمد", "status": "نشط"},
      {"number": "2", "name": "محمد", "status": "غير نشط"},
      {"number": "4", "name": "سالم", "status": "نشط"},
    ];

    final result = ComparisonDiffService.compareTwoMonths(
      monthA: monthA,
      monthB: monthB,
    );

    setState(() {
      diff = result;
    });
  }

  Widget card(String title, int value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final summary = diff?["summary"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة القيادة العسكرية"),
        backgroundColor: Colors.blue,
      ),

      body: diff == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  // 📊 الإحصائيات
                  Row(
                    children: [
                      card(
                        "جدد",
                        summary["newCount"] ?? 0,
                        Colors.green,
                        Icons.person_add,
                      ),
                      card(
                        "غائبين",
                        summary["missingCount"] ?? 0,
                        Colors.red,
                        Icons.person_off,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      card(
                        "متغيرين",
                        summary["changedCount"] ?? 0,
                        Colors.orange,
                        Icons.swap_horiz,
                      ),
                      card(
                        "ثابتين",
                        summary["stableCount"] ?? 0,
                        Colors.blue,
                        Icons.check_circle,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  const Text(
                    "ملخص الحالة العامة",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    (summary["missingCount"] ?? 0) > 0
                        ? "⚠️ يوجد تغيّر غير طبيعي في الأفراد"
                        : "✅ الوضع مستقر",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // 🧠 زر التقرير الذكي
                  ElevatedButton(
                    onPressed: () {
                      if (diff == null) return;

                      final text =
                          SmartReportService.generateReport(diff!);

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("التقرير الذكي"),
                          content: SingleChildScrollView(
                            child: Text(text),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("إغلاق"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("إنشاء تقرير ذكي"),
                  ),
                ],
              ),
            ),
    );
  }
}
