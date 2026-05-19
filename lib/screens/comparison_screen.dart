import 'package:flutter/material.dart';
import '../services/monthly_comparison_service.dart';
import '../export/monthly_comparison_pdf.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});
  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  bool loading = true;
  List<String> months = ["2026-01", "2026-02", "2026-03"];
  String fromMonth = "2026-01";
  String toMonth = "2026-03";
  List<Map<String, dynamic>> result = [];
  List<String> selectedMonths = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    int start = months.indexOf(fromMonth);
    int end = months.indexOf(toMonth);
    if (start > end) { int temp = start; start = end; end = temp; }
    selectedMonths = months.sublist(start, end + 1);
    final data = await MonthlyComparisonService.build(months: selectedMonths);
    setState(() {
      result = List<Map<String, dynamic>>.from(data["people"]);
      loading = false;
    });
  }

  Future<void> exportPdf() async {
    final data = await MonthlyComparisonService.build(months: selectedMonths);
    final people = List<Map<String, dynamic>>.from(data["people"]);
    final monthsList = List<String>.from(data["months"]);

    // هذا هو الاستدعاء المبسط الذي سيحل المشكلة
    final path = await MonthlyComparisonPdf.export(
      months: monthsList,
      people: people,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم الحفظ: $path")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المباينة العسكرية")),
      body: loading ? const Center(child: CircularProgressIndicator()) : Container()
    );
  }
}
