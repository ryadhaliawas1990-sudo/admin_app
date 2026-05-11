import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/db_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, int> monthlyData = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  // =========================
  // 📊 LOAD DATA
  // =========================

  Future<void> loadAnalytics() async {
    final db = await DBHelper.database;

    final result = await db.rawQuery('''
      SELECT month, COUNT(*) as count
      FROM people
      GROUP BY month
      ORDER BY month ASC
    ''');

    Map<String, int> data = {};

    for (var row in result) {
      data[row['month'].toString()] = row['count'] as int;
    }

    setState(() {
      monthlyData = data;
      loading = false;
    });
  }

  // =========================
  // 📊 BUILD CHART
  // =========================

  List<BarChartGroupData> buildBars() {
    int index = 0;

    return monthlyData.entries.map((e) {
      final value = e.value.toDouble();

      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 18,
          ),
        ],
      );
    }).toList();
  }

  List<String> getLabels() {
    return monthlyData.keys.toList();
  }

  // =========================
  // 🧠 UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تحليل البيانات"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  const Text(
                    "📊 حركة الموظفين حسب الشهر",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: BarChart(
                      BarChartData(
                        barGroups: buildBars(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = getLabels();

                                if (value.toInt() < labels.length) {
                                  return Text(labels[value.toInt()]);
                                }

                                return const Text("");
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
