import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int peopleCount = 0;
  int reportsCount = 0;
  int logsCount = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final people = await DBHelper.getPeople();
    final reports = await DBHelper.getReports();
    final logs = await DBHelper.getLogs();

    setState(() {
      peopleCount = people.length;
      reportsCount = reports.length;
      logsCount = logs.length;
      loading = false;
    });
  }

  Widget buildBar(String title, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "$title ($value)",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value == 0 ? 0.05 : (value / (peopleCount + reportsCount + logsCount + 1)),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("التحليلات"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadStats,
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "📊 تحليل النظام",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildBar("الموظفين", peopleCount, Colors.blue),
                  buildBar("التقارير", reportsCount, Colors.red),
                  buildBar("العمليات", logsCount, Colors.orange),

                  const SizedBox(height: 20),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.insights),
                      title: const Text("ملخص النظام"),
                      subtitle: Text(
                        "إجمالي العمليات: ${peopleCount + reportsCount + logsCount}",
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
