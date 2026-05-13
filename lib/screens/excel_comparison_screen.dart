  }
}
import 'package:flutter/material.dart';

import '../services/excel_comparison_engine.dart';
import '../services/excel_import_service.dart';

class ExcelComparisonScreen extends StatefulWidget {
  const ExcelComparisonScreen({super.key});

  @override
  State<ExcelComparisonScreen> createState() => _ExcelComparisonScreenState();
}

class _ExcelComparisonScreenState extends State<ExcelComparisonScreen> {

  List<Map<String, dynamic>>? listA;
  List<Map<String, dynamic>>? listB;

  Map<String, dynamic>? result;

  Future<void> pickA() async {
    final data = await ExcelImportService.pickAndReadExcel();

    setState(() {
      listA = data;
    });
  }

  Future<void> pickB() async {
    final data = await ExcelImportService.pickAndReadExcel();

    setState(() {
      listB = data;
    });
  }

  void compare() {

    if (listA == null || listB == null) return;

    final res = ExcelComparisonEngine.compare(
      listA: listA!,
      listB: listB!,
    );

    setState(() {
      result = res;
    });
  }

  @override
  Widget build(BuildContext context) {

    final summary = result?["summary"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("مقارنة الكشوفات Excel"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            const Text(
              "تصميم رياض عواس",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: pickA,
                    child: const Text("تحميل كشف A"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: pickB,
                    child: const Text("تحميل كشف B"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: compare,
              child: const Text("مقارنة"),
            ),

            const SizedBox(height: 20),

            if (result != null) ...[

              Row(
                children: [
                  _card("في الاثنين", summary["inBothCount"] ?? 0),
                  _card("A فقط", summary["onlyACount"] ?? 0),
                  _card("B فقط", summary["onlyBCount"] ?? 0),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [

                    _section("في الاثنين", result!["inBoth"]),
                    _section("فقط في A", result!["onlyA"]),
                    _section("فقط في B", result!["onlyB"]),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _card(String title, int value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text("$value", style: const TextStyle(fontSize: 20)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...list.map((e) => ListTile(
          title: Text(e["name"] ?? ""),
          subtitle: Text(e["number"] ?? ""),
        )),
      ],
    );
  }
}
