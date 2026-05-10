import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/monthly_comparison_pdf.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> people = [];
  List<String> selectedMonths = [];
  List<String> selectedNumbers = [];

  final manualNumberController = TextEditingController();

  final List<String> months = [
    "2026-01",
    "2026-02",
    "2026-03",
  ];

  @override
  void initState() {
    super.initState();
    loadPeople();
  }

  Future<void> loadPeople() async {
    final data = await DBHelper.getPeople();

    setState(() {
      people = data;
    });
  }

  void togglePerson(String number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else {
        selectedNumbers.add(number);
      }
    });
  }

  void toggleMonth(String month) {
    setState(() {
      if (selectedMonths.contains(month)) {
        selectedMonths.remove(month);
      } else {
        selectedMonths.add(month);
      }
    });
  }

  void addManualNumber() {
    if (manualNumberController.text.isNotEmpty) {
      setState(() {
        selectedNumbers.add(manualNumberController.text);
        manualNumberController.clear();
      });
    }
  }

  void generatePdf() {
    MonthlyComparisonPdf.export(
      selectedMonths.isEmpty ? months : selectedMonths,
      numbers: selectedNumbers.isEmpty ? null : selectedNumbers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إنشاء التقرير الذكي"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            // 📅 اختيار الأشهر
            const Text(
              "اختيار الأشهر",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Wrap(
              spacing: 8,
              children: months.map((month) {
                final selected = selectedMonths.contains(month);

                return FilterChip(
                  label: Text(month),
                  selected: selected,
                  onSelected: (_) => toggleMonth(month),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // 👤 إدخال رقم يدوي
            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: manualNumberController,
                    decoration: const InputDecoration(
                      labelText: "إدخال رقم شخص",
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: addManualNumber,
                  child: const Text("إضافة"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 👥 قائمة الأشخاص
            const Text(
              "اختيار الأشخاص",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: people.length,
                itemBuilder: (context, index) {
                  final p = people[index];
                  final number = p['number'];

                  final isSelected = selectedNumbers.contains(number);

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(p['name'] ?? ''),
                    subtitle: Text("رقم: $number"),
                    onChanged: (_) => togglePerson(number),
                  );
                },
              ),
            ),

            // 📊 زر إنشاء التقرير
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: generatePdf,
                child: const Text("📊 إنشاء المباينة PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
