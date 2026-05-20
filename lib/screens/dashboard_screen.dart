import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  int totalPeople = 0;
  int totalRecords = 0;
  int totalYears = 0;

  Map<String, int> statusCount = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {

    try {

      final db = await DBHelper.database;

      final people = await db.rawQuery('''
        SELECT COUNT(DISTINCT number) as count
        FROM timeline
      ''');

      final records = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM timeline
      ''');

      final years = await db.rawQuery('''
        SELECT COUNT(DISTINCT year) as count
        FROM timeline
      ''');

      final statuses = await db.rawQuery('''
        SELECT status, COUNT(*) as count
        FROM timeline
        GROUP BY status
      ''');

      Map<String, int> statusMap = {};

      for (var s in statuses) {
        statusMap[s['status'].toString()] =
            int.tryParse(s['count'].toString()) ?? 0;
      }

      if (!mounted) return;

      setState(() {
        totalPeople = (people.isNotEmpty ? people.first['count'] : 0) as int;
        totalRecords = (records.isNotEmpty ? records.first['count'] : 0) as int;
        totalYears = (years.isNotEmpty ? years.first['count'] : 0) as int;
        statusCount = statusMap;
        loading = false;
      });

    } catch (e) {

      print("DASHBOARD ERROR: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(child: _card("الأفراد", totalPeople)),
                      const SizedBox(width: 10),
                      Expanded(child: _card("السجلات", totalRecords)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _card("السنوات المسجلة", totalYears),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "توزيع الحالات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: GridView.builder(
                      itemCount: statusCount.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2,
                      ),
                      itemBuilder: (context, index) {

                        final key = statusCount.keys.elementAt(index);
                        final value = statusCount[key]!;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueGrey),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _card(String title, int value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
