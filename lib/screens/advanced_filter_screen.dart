import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class AdvancedFilterScreen extends StatefulWidget {
  const AdvancedFilterScreen({super.key});

  @override
  State<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {

  String? selectedYear;
  String? selectedStatus;
  String? selectedUnit;

  List<Map<String, dynamic>> results = [];

  bool loading = false;

  List<String> years = [];
  List<String> statuses = [];
  List<String> units = [];

  @override
  void initState() {
    super.initState();
    loadFilters();
  }

  Future<void> loadFilters() async {

    final db = await DBHelper.database;

    final yearData = await db.rawQuery(
      "SELECT DISTINCT year FROM timeline",
    );

    final statusData = await db.rawQuery(
      "SELECT DISTINCT status FROM timeline",
    );

    final unitData = await db.rawQuery(
      "SELECT DISTINCT unit FROM timeline",
    );

    setState(() {
      years = yearData.map((e) => e['year'].toString()).toList();
      statuses = statusData.map((e) => e['status'].toString()).toList();
      units = unitData.map((e) => e['unit'].toString()).toList();
    });
  }

  Future<void> applyFilter() async {

    setState(() => loading = true);

    final db = await DBHelper.database;

    String query = "SELECT * FROM timeline WHERE 1=1";
    List args = [];

    if (selectedYear != null) {
      query += " AND year = ?";
      args.add(selectedYear);
    }

    if (selectedStatus != null) {
      query += " AND status = ?";
      args.add(selectedStatus);
    }

    if (selectedUnit != null) {
      query += " AND unit = ?";
      args.add(selectedUnit);
    }

    final data = await db.rawQuery(query, args);

    setState(() {
      results = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("فلترة متقدمة"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // السنة
            DropdownButtonFormField(
              value: selectedYear,
              items: years.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedYear = v),
              decoration: const InputDecoration(labelText: "السنة"),
            ),

            // الحالة
            DropdownButtonFormField(
              value: selectedStatus,
              items: statuses.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedStatus = v),
              decoration: const InputDecoration(labelText: "الحالة"),
            ),

            // الوحدة
            DropdownButtonFormField(
              value: selectedUnit,
              items: units.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedUnit = v),
              decoration: const InputDecoration(labelText: "الوحدة"),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: applyFilter,
                child: const Text("تطبيق الفلتر"),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {

                        final item = results[index];

                        return Card(
                          child: ListTile(
                            title: Text(item['name'] ?? ''),
                            subtitle: Text(
                              "رقم: ${item['number']} | حالة: ${item['status']}",
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
}
