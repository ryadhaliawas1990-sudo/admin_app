import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../export/system_full_report.dart';

import 'hr_screen.dart';
import 'comparison_screen.dart';
import 'reports_archive_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int peopleCount = 0;
  int reportsCount = 0;
  String lastActivity = "لا يوجد نشاط بعد";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final people = await DBHelper.getPeople();
    final reports = await DBHelper.getReports();
    final logs = await DBHelper.getLogs();

    setState(() {
      peopleCount = people.length;
      reportsCount = reports.length;

      if (logs.isNotEmpty) {
        lastActivity = logs.first["action"] ?? "لا يوجد نشاط";
      }
    });
  }

  Future<void> generateSystemReport() async {
    final path = await SystemFullReport.generate();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم إنشاء التقرير: $path")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [

            // =======================
            // 📊 الإحصائيات
            // =======================
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "الموظفين",
                    peopleCount.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    "التقارير",
                    reportsCount.toString(),
                    Icons.picture_as_pdf,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =======================
            // 🧠 آخر نشاط
            // =======================
            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text("آخر نشاط"),
                subtitle: Text(lastActivity),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: loadData,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =======================
            // 📦 القائمة
            // =======================
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [

                _menuCard(
                  "الموظفين",
                  Icons.people,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HrScreen(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  "التقارير",
                  Icons.picture_as_pdf,
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComparisonScreen(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  "الأرشيف",
                  Icons.folder,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsArchiveScreen(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  "التحليلات",
                  Icons.bar_chart,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ),

                _menuCard(
                  "تقرير النظام PDF",
                  Icons.assessment,
                  Colors.purple,
                  () async {
                    await generateSystemReport();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // 📊 كروت الإحصائيات
  // =======================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  // =======================
  // 📦 كروت القائمة
  // =======================
  Widget _menuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}
