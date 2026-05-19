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

  List<String> months = [
    "2026-01",
    "2026-02",
    "2026-03",
  ];

  String fromMonth = "2026-01";
  String toMonth = "2026-03";

  List<Map<String, dynamic>> result = [];

  List<String> selectedMonths = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  // =========================
  // 📊 تحميل المباينة من DB الحقيقي
  // =========================
  Future<void> load() async {
    setState(() => loading = true);

    int start = months.indexOf(fromMonth);
    int end = months.indexOf(toMonth);

    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    selectedMonths = months.sublist(start, end + 1);

    final data = await MonthlyComparisonService.build(
      months: selectedMonths,
    );

    setState(() {
      result = List<Map<String, dynamic>>.from(data["people"]);
      loading = false;
    });
  }

  // =========================
  // 📈 حساب النسبة
  // =========================
  double calcPercent(Map<String, dynamic> person) {
    final monthsMap = person["months"] as Map<String, dynamic>;

    if (monthsMap.isEmpty) return 0;

    int total = monthsMap.length;
    int present = monthsMap.values.where((v) => v == "نشط" || v == true).length;

    return present / total;
  }

  // =========================
  // 📤 PDF (الربط النهائي)
  // =========================
  Future<void> exportPdf() async {

    final data = await MonthlyComparisonService.build(
      months: selectedMonths,
    );

    final people = List<Map<String, dynamic>>.from(data["people"]);
    final monthsList = List<String>.from(data["months"]);

    final pdfData = <String, dynamic>{};

    for (var p in people) {
      pdfData[p["number"]] = {
        "months": p["months"]
      };
    }

    final path = await MonthlyComparisonPdf.export(
      months: monthsList,
      people: people,
      pdfData,
      topText: "تقرير المباينة النهائي",
      leftSignature: "القائد",
      rightSignature: "شؤون الأفراد",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ PDF: $path")),
    );
  }

  // =========================
  // 📤 Excel (لاحقاً)
  // =========================
  Future<void> exportExcel() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Excel سيتم ربطه لاحقاً")),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المباينة العسكرية"),
        backgroundColor: Colors.blue,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // 📅 اختيار الفترة
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [

                      Expanded(
                        child: DropdownButton<String>(
                          value: fromMonth,
                          isExpanded: true,
                          items: months.map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text("من: $m"),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => fromMonth = v!);
                            load();
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: DropdownButton<String>(
                          value: toMonth,
                          isExpanded: true,
                          items: months.map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text("إلى: $m"),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => toMonth = v!);
                            load();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 📤 أزرار التصدير
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [

                      Expanded(
                        child: ElevatedButton(
                          onPressed: exportPdf,
                          child: const Text("PDF"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: exportExcel,
                          child: const Text("Excel"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 📋 الجدول
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [

                          const DataColumn(label: Text("الرقم")),
                          const DataColumn(label: Text("الاسم")),
                          const DataColumn(label: Text("الرتبة")),

                          ...selectedMonths.map(
                            (m) => DataColumn(label: Text(m)),
                          ),

                          const DataColumn(label: Text("النسبة")),
                        ],

                        rows: result.map((p) {

                          final monthsMap =
                              p["months"] as Map<String, dynamic>;

                          return DataRow(
                            cells: [

                              DataCell(Text(p["number"] ?? "")),
                              DataCell(Text(p["name"] ?? "")),
                              DataCell(Text(p["rank"] ?? "")),

                              ...selectedMonths.map((m) {
                                final value = monthsMap[m];
                                final ok = value == "نشط" || value == true;

                                return DataCell(
                                  Text(
                                    ok ? "✔" : "✖",
                                    style: TextStyle(
                                      color: ok
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),

                              DataCell(
                                Text(
                                  "${(calcPercent(p) * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
