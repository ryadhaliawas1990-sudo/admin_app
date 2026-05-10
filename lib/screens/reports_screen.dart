import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int total = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await DBHelper.getPeople();

    setState(() {
      total = data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التقارير"),
        centerTitle: true,
      ),

      body: Center(
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bar_chart, size: 60, color: Colors.blue),
                const SizedBox(height: 10),
                const Text("إجمالي الموظفين"),
                Text(
                  "$total",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
