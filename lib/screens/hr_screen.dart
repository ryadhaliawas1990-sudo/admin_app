import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../export/excel_export.dart';
import '../data/excel_import.dart';
import '../export/monthly_comparison_pdf.dart';
import '../core/app_refresher.dart';
import '../core/military_units.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final rankController = TextEditingController();
  final statusController = TextEditingController();

  List<Map<String, dynamic>> people = [];
  String searchQuery = "";
  String selectedMonth = "2026-01";

  String selectedUnit = MilitaryUnits.units.first;

  @override
  void initState() {
    super.initState();
    loadData();

    AppRefresher.refreshNotifier.addListener(() {
      loadData();
    });
  }

  Future<void> loadData() async {
    final data = searchQuery.isEmpty
        ? await DBHelper.getPeople()
        : await DBHelper.searchPeople(searchQuery);

    if (!mounted) return;

    setState(() {
      people = data;
    });
  }

  Future<void> addPerson() async {
    await DBHelper.insertPerson({
      "name": nameController.text,
      "number": numberController.text,
      "rank": rankController.text,
      "unit": selectedUnit,
      "status": statusController.text,
      "month": selectedMonth,
    });

    _clearInputs();
    loadData();
  }

  Future<void> updatePerson(int id) async {
    await DBHelper.updatePerson(id, {
      "name": nameController.text,
      "number": numberController.text,
      "rank": rankController.text,
      "unit": selectedUnit,
      "status": statusController.text,
      "month": selectedMonth,
    });

    if (!mounted) return;
    Navigator.pop(context);
    loadData();
  }

  Future<void> deletePerson(int id) async {
    await DBHelper.deletePerson(id);
    loadData();
  }

  Future<void> exportExcel() async {
    final path = await ExcelExport.exportToExcel(people);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ Excel في: $path")),
    );
  }

  Future<void> importExcel() async {
    await ExcelImport.pickAndImport(selectedMonth);
    loadData();
  }

  Future<void> exportComparisonPdf() async {
    await MonthlyComparisonPdf.export(
      ["2026-01", "2026-02", "2026-03"],
    );
  }

  void _clearInputs() {
    nameController.clear();
    numberController.clear();
    rankController.clear();
    statusController.clear();
  }

  void openEditDialog(Map<String, dynamic> p) {
    nameController.text = p["name"] ?? "";
    numberController.text = p["number"] ?? "";
    rankController.text = p["rank"] ?? "";
    statusController.text = p["status"] ?? "";

    selectedUnit = (p["unit"] ?? MilitaryUnits.units.first).toString();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("تعديل البيانات"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: nameController),
                  TextField(controller: numberController),
                  TextField(controller: rankController),

                  const SizedBox(height: 10),

                  DropdownButton<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    items: MilitaryUnits.units
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        selectedUnit = v!;
                      });
                    },
                  ),

                  TextField(controller: statusController),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await updatePerson(p["id"]);
                },
                child: const Text("حفظ"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ AppBar المحسن (كما طلبت)
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "نظام الموارد البشرية العسكري",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "إدارة الأفراد - المباينة - التقارير",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.blue,
      ),

      body: Column(
        children: [

          // 🔍 البحث
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "بحث",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                loadData();
              },
            ),
          ),

          // 📋 القائمة
          Expanded(
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final p = people[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(p["name"] ?? ""),
                    subtitle: Text(
                      "رقم: ${p["number"]} | وحدة: ${p["unit"]}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => openEditDialog(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletePerson(p["id"]),
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
    );
  }
}
