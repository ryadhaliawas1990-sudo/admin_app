import 'package:flutter/material.dart';
import '../services/military_comparison_engine.dart';

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

    // 👤 الأشخاص
    final people = [
      {"number": "1", "name": "أحمد"},
      {"number": "2", "name": "محمد"},
      {"number": "3", "name": "خالد"},
    ];

    // 📅 الأشهر
    final months = ["2026-01", "2026-02"];

    // 📊 بيانات الأشهر (الحالة من Excel لاحقًا)
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

    final res = MilitaryComparisonEngine.compare(
      people: people,
      months: months,
      dataByMonth: dataByMonth,
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

                  Text(
                    "تصميم رياض عواس",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  // 📊 إحصائيات
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
