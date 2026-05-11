import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/system_full_report.dart';
import 'package:open_file/open_file.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? lastActivity;
  int peopleCount = 0;
  int reportsCount = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  // =========================
  // 📊 LOAD DASHBOARD DATA
  // =========================

  Future<void> loadStats() async {
    final db = await DBHelper.database;

    final people = await db.rawQuery('SELECT COUNT(*) as count FROM people');
    final reports = await db.rawQuery('SELECT COUNT(*) as count FROM reports');

    final activity = await DBHelper.getLastActivity();

    setState(() {
      peopleCount = people.first['count'] as int;
      reportsCount = reports.first['count'] as int;
      lastActivity = activity;
    });
  }

  // =========================
  // 📊 FULL SYSTEM REPORT
  // =========================

  Future<void> generateFullReport() async {
    final path = await SystemFullReport.generate();

    await DBHelper.updateLastActivity();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📊 تم إنشاء التقرير الكامل"),
      ),
    );

    OpenFile.open(path);

    loadStats();
  }

  // =========================
  // 🧠 UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // =========================
            // 📊 STATS CARDS
            // =========================

            Row(
              children: [

                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("👥 الموظفين"),
                          Text(
                            "$peopleCount",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text("📁 التقارير"),
                          Text(
                            "$reportsCount",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =========================
            // 🧠 LAST ACTIVITY
            // =========================

            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text("آخر نشاط"),
                subtitle: Text(
                  lastActivity ?? "لا يوجد نشاط بعد",
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // 🚀 ACTION BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: generateFullReport,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("📊 إنشاء تقرير النظام الكامل"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // =========================
            // 🔄 REFRESH
            // =========================

            TextButton.icon(
              onPressed: loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text("تحديث البيانات"),
            ),
          ],
        ),
      ),
    );
  }
}
