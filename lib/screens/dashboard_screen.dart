import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    // 👤 بيانات تجريبية (بدون Engine خارجي)
    final people = [
      {"number": "1", "name": "أحمد"},
      {"number": "2", "name": "محمد"},
      {"number": "3", "name": "خالد"},
    ];

    final months = ["2026-01", "2026-02"];

    final dataByMonth = {
      "2026-01": [
        {"number": "1", "status": "نشط"},
        {"number": "2", "status": "نشط"},
      ],
      "2026-02": [
        {"number": "1", "status": "غير نشط"},
        {"number": "3", "status": "نشط"},
      ],
    };

    // 🧠 منطق مباينة داخلي بسيط (بدون أي ملف خارجي)
    final List<Map<String, dynamic>> results = [];

    int newCount = 0;
    int missingCount = 0;
    int changedCount = 0;
    int stableCount = 0;

    for (final p in people) {

      final monthsMap = <String, bool>{};

      for (final m in months) {
        final list = dataByMonth[m] ?? [];

        final found = list.any((e) => e["number"] == p["number"]);

        monthsMap[m] = found;

        if (found && m == "2026-01") stableCount++;
        if (!found && m == "2026-02") missingCount++;
      }

      results.add({
        "number": p["number"],
        "name": p["name"],
        "months": monthsMap,
      });
    }

    setState(() {
      result = {
        "result": results,
        "summary": {
          "newCount": newCount,
          "missingCount": missingCount,
          "changedCount": changedCount,
          "stableCount": stableCount,
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {

    final summary = result?["summary"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة المباينة"),
        backgroundColor: Colors.blue,
      ),

      body: result == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "تصميم رياض عواس",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _card("جدد", summary["newCount"] ?? 0, Colors.green),
                      _card("غائبين", summary["missingCount"] ?? 0, Colors.red),
                    ],
                  ),

                  Row(
                    children: [
                      _card("متغيرين", summary["changedCount"] ?? 0, Colors.orange),
                      _card("ثابتين", summary["stableCount"] ?? 0, Colors.blue),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "نتيجة المباينة",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: result!["result"].length,
                      itemBuilder: (context, index) {

                        final item = result!["result"][index];
                        final monthsMap = item["months"];

                        return Card(
                          child: ListTile(
                            title: Text(item["name"]),
                            subtitle: Text(item["number"]),
                            trailing: Text(monthsMap.toString()),
                          ),
                        );
                      },
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text("$value", style: TextStyle(color: color, fontSize: 20)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
