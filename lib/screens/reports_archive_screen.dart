import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/monthly_comparison_pdf.dart';
import 'hr_screen.dart';

class ReportsArchiveScreen extends StatefulWidget {
  const ReportsArchiveScreen({super.key});

  @override
  State<ReportsArchiveScreen> createState() =>
      _ReportsArchiveScreenState();
}

class _ReportsArchiveScreenState extends State<ReportsArchiveScreen> {

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
      } else if (status.contains("غير") || status.contains("inactive")) {
        i++;
      } else {
        u++;
      }
    }

    setState(() {
      totalPeople = people.length;
      totalReports = reports.length;

      active = a;
      inactive = i;
      unknown = u;

      alertMessage = "النظام يعمل بشكل طبيعي";

      loading = false;
    });
  }

  // ✅ التصدير الصحيح
  Future<void> openComparison() async {

    final people = await DBHelper.getPeople();

    await MonthlyComparisonPdf.export(
      months: [
        "2026-01",
        "2026-02",
        "2026-03",
      ],
      people: people,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Reports Archive"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text("إجمالي الأفراد"),
                      trailing: Text("$totalPeople"),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text("إجمالي التقارير"),
                      trailing: Text("$totalReports"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(alertMessage),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: openComparison,
                    child: const Text("تصدير PDF"),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
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
                ],
              ),
            ),
    );
  }
}
