import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'hr_screen.dart';
import '../export/monthly_comparison_pdf.dart';
import 'reports_archive_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalPeople = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final data = await DBHelper.getPeople();

    setState(() {
      totalPeople = data.length;
    });
  }

  Future<void> openComparison() async {
    final path = await MonthlyComparisonPdf.export([
      "2026-01",
      "2026-02",
      "2026-03",
    ]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ المباينة: $path")),
    );
  }

  void openArchive() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportsArchiveScreen(),
      ),
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

        leading: const Icon(Icons.dashboard),

        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                "تصميم: م/رياض عواس - 781927044",
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 📊 كروت الإحصائيات
            Row(
              children: [

                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.people, size: 40, color: Colors.blue),
                          const SizedBox(height: 10),
                          Text(
                            "$totalPeople",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("إجمالي الأفراد"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📌 أزرار النظام
            _buildButton(
              icon: Icons.people,
              text: "إدارة الموارد البشرية",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HrScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            _buildButton(
              icon: Icons.picture_as_pdf,
              text: "إنشاء المباينة (PDF)",
              color: Colors.green,
              onTap: openComparison,
            ),

            const SizedBox(height: 10),

            _buildButton(
              icon: Icons.folder,
              text: "أرشيف التقارير",
              color: Colors.orange,
              onTap: openArchive,
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 زر موحد بتصميم احترافي
  Widget _buildButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onPressed: onTap,
      ),
    );
  }
}
