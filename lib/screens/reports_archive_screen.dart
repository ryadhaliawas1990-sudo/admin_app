import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'hr_screen.dart';
import 'reports_archive_screen.dart';
import '../export/monthly_comparison_pdf.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalPeople = 0;
  int totalReports = 0;

  int active = 0;
  int inactive = 0;
  int unknown = 0;

  bool loading = true;

  String alertMessage = "";

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    setState(() => loading = true);

    final people = await DBHelper.getPeople();
    final reports = await DBHelper.getReports();

    int a = 0;
    int i = 0;
    int u = 0;

    for (var p in people) {
      final status = (p["status"] ?? "").toString().toLowerCase();

      if (status.contains("نشط") || status.contains("active")) {
        a++;
      } else if (status.contains("غير") ||
          status.contains("inactive")) {
        i++;
      } else {
        u++;
      }
    }

    // 🧠 تحليل ذكي بسيط
    String alert = "";
    if (a < i) {
      alert = "⚠️ عدد غير النشطين أعلى من النشطين";
    } else if (reports.isEmpty) {
      alert = "📁 لا توجد تقارير محفوظة بعد";
    } else {
      alert = "✅ النظام يعمل بشكل طبيعي";
    }

    setState(() {
      totalPeople = people.length;
      totalReports = reports.length;

      active = a;
      inactive = i;
      unknown = u;

      alertMessage = alert;
      loading = false;
    });
  }

  void openComparison() {
    MonthlyComparisonPdf.export([
      "2026-01",
      "2026-02",
      "2026-03",
    ]);
  }

  double percent(int value) {
    if (totalPeople == 0) return 0;
    return value / totalPeople;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Smart ERP Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAnalytics,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  // 📊 KPIs
                  Row(
                    children: [
                      _card("الأفراد", totalPeople, Colors.blue),
                      _card("التقارير", totalReports, Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 📊 نسب
                  _bar("نشط", percent(active), Colors.green),
                  _bar("غير نشط", percent(inactive), Colors.red),
                  _bar("غير معروف", percent(unknown), Colors.grey),

                  const SizedBox(height: 15),

                  // 🧠 تنبيه ذكي
                  Card(
                    color: Colors.black87,
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      title: Text(
                        alertMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🚀 الأزرار
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HrScreen(),
                              ),
                            );
                          },
                          child: const Text("HR"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReportsArchiveScreen(),,
                              ),
                            );
                          },
                          child: const Text("الأرشيف"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: openComparison,
                      child: const Text("إنشاء تقرير مباينة"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(String title, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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

  Widget _bar(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title ${(value * 100).toStringAsFixed(1)}%"),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
