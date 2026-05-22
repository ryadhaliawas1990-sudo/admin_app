import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class AdvancedFilterScreen extends StatefulWidget {
  const AdvancedFilterScreen({super.key});

  @override
  State<AdvancedFilterScreen> createState() =>
      _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState
    extends State<AdvancedFilterScreen> {

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
      "SELECT DISTINCT year FROM timeline ORDER BY year DESC",
    );

    final statusData = await db.rawQuery(
      "SELECT DISTINCT status FROM timeline",
    );

    final unitData = await db.rawQuery(
      "SELECT DISTINCT unit FROM timeline",
    );

    setState(() {

      years = yearData
          .map((e) => e['year'].toString())
          .where((e) => e.isNotEmpty)
          .toList();

      statuses = statusData
          .map((e) => e['status'].toString())
          .where((e) => e.isNotEmpty)
          .toList();

      units = unitData
          .map((e) => e['unit'].toString())
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  Future<void> applyFilter() async {

    setState(() => loading = true);

    final db = await DBHelper.database;

    String query =
        "SELECT * FROM timeline WHERE 1=1";

    List<dynamic> args = [];

    if (selectedYear != null &&
        selectedYear!.isNotEmpty) {

      query += " AND year = ?";
      args.add(selectedYear);
    }

    if (selectedStatus != null &&
        selectedStatus!.isNotEmpty) {

      query += " AND status = ?";
      args.add(selectedStatus);
    }

    if (selectedUnit != null &&
        selectedUnit!.isNotEmpty) {

      query += " AND unit = ?";
      args.add(selectedUnit);
    }

    query += " ORDER BY id DESC";

    final data = await db.rawQuery(
      query,
      args,
    );

    if (!mounted) return;

    setState(() {
      results = data;
      loading = false;
    });
  }

  Widget buildDropdown({
    required String title,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {

    return DropdownButtonFormField<String>(

      initialValue: value,

      items: items.map((e) {

        return DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        );

      }).toList(),

      onChanged: onChanged,

      decoration: InputDecoration(
        labelText: title,
        border: const OutlineInputBorder(),
      ),
    );
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

            buildDropdown(
              title: "السنة",
              items: years,
              value: selectedYear,
              onChanged: (v) {
                setState(() {
                  selectedYear = v;
                });
              },
            ),

            const SizedBox(height: 12),

            buildDropdown(
              title: "الحالة",
              items: statuses,
              value: selectedStatus,
              onChanged: (v) {
                setState(() {
                  selectedStatus = v;
                });
              },
            ),

            const SizedBox(height: 12),

            buildDropdown(
              title: "الوحدة",
              items: units,
              value: selectedUnit,
              onChanged: (v) {
                setState(() {
                  selectedUnit = v;
                });
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: applyFilter,
                child: const Text("تطبيق الفلتر"),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(

              child: loading

                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : results.isEmpty

                      ? const Center(
                          child: Text(
                            "لا توجد نتائج",
                          ),
                        )

                      : ListView.builder(

                          itemCount: results.length,

                          itemBuilder: (context, index) {

                            final item = results[index];

                            return Card(

                              child: ListTile(

                                title: Text(
                                  item['name']
                                          ?.toString() ??
                                      '',
                                ),

                                subtitle: Text(
                                  "الرقم: ${item['number']} | الحالة: ${item['status']} | الوحدة: ${item['unit']}",
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
