import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/monthly_comparison_pdf.dart';
import 'hr_screen.dart';

class ReportsArchiveScreen extends StatefulWidget {
  const ReportsArchiveScreen({super.key});

  @override
  State<ReportsArchiveScreen> createState() => _ReportsArchiveScreenState();
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

      alertMessage = "النظام يعمل";
      loading = false;
    });
  }

  // ✅ FIXED
  void openComparison() async {
    await MonthlyComparisonPdf.export(
      months: ["2026-01", "2026-02", "2026-03"],
      people: await DBHelper.getPeople(),
      data: {
        for (var p in await DBHelper.getPeople())
          p["number"]: {"months": {}}
      },
      topText: "تقرير المباينة",
      leftSignature: "القائد",
      rightSignature: "شؤون الأفراد",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Center(
        child: ElevatedButton(
          onPressed: openComparison,
          child: const Text("تقرير"),
        ),
      ),
    );
  }
}
