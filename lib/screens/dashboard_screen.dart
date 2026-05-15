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

    setState(() {
      totalPeople = people.first['count'] as int;
      totalRecords = records.first['count'] as int;
      totalYears = years.first['count'] as int;
      statusCount = statusMap;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _card("عدد الأفراد", "$totalPeople"),
                  _card("عدد السجلات", "$totalRecords"),
                  _card("عدد السنوات", "$totalYears"),

                  const SizedBox(height: 20),

                  const Text(
                    "توزيع الحالات",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: statusCount.entries.map((e) {
                        return Card(
                          child: ListTile(
                            title: Text(e.key),
                            trailing: Text("${e.value}"),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
