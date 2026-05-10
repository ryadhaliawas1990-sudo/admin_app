import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/excel_export.dart';
import '../data/excel_import.dart';
import '../export/monthly_comparison_pdf.dart'; // 🔥 إضافة المباينة

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final rankController = TextEditingController();
  final unitController = TextEditingController();
  final statusController = TextEditingController();

  List<Map<String, dynamic>> people = [];
  String searchQuery = "";

  String selectedMonth = "2026-01";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    List<Map<String, dynamic>> data;

    if (searchQuery.isEmpty) {
      data = await DBHelper.getPeople();
    } else {
      data = await DBHelper.searchPeople(searchQuery);
    }

    setState(() {
      people = data;
    });
  }

  Future<void> addPerson() async {
    await DBHelper.insertPerson({
      "name": nameController.text,
      "number": numberController.text,
      "rank": rankController.text,
      "unit": unitController.text,
      "status": statusController.text,
      "month": selectedMonth,
    });

    nameController.clear();
    numberController.clear();
    rankController.clear();
    unitController.clear();
    statusController.clear();

    loadData();
  }

  Future<void> deletePerson(int id) async {
    await DBHelper.deletePerson(id);
    loadData();
  }

  Future<void> exportExcel() async {
    final path = await ExcelExport.exportToExcel(people);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ Excel في: $path")),
    );
  }

  Future<void> importExcel() async {
    await ExcelImport.pickAndImport(selectedMonth);
    loadData();
  }

  // 🔥 زر المباينة PDF
  Future<void> exportComparisonPdf() async {
    await MonthlyComparisonPdf.export([
      "2026-01",
      "2026-02",
      "2026-03",
    ]);
  }

  void openEditDialog(Map<String, dynamic> p) {
    nameController.text = p["name"] ?? "";
    numberController.text = p["number"] ?? "";
    rankController.text = p["rank"] ?? "";
    unitController.text = p["unit"] ?? "";
    statusController.text = p["status"] ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل البيانات"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController),
              TextField(controller: numberController),
              TextField(controller: rankController),
              TextField(controller: unitController),
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
              await DBHelper.updatePerson(p["id"], {
                "name": nameController.text,
                "number": numberController.text,
                "rank": rankController.text,
                "unit": unitController.text,
                "status": statusController.text,
                "month": selectedMonth,
              });

              Navigator.pop(context);
              loadData();
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("نظام الموارد البشرية"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),

      body: Column(
        children: [

          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "بحث بالاسم أو الرقم",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                loadData();
              },
            ),
          ),

          // 📅 الشهر + الأزرار
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [

                const Text("الشهر: "),
                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: selectedMonth,
                  items: const [
                    DropdownMenuItem(value: "2026-01", child: Text("يناير")),
                    DropdownMenuItem(value: "2026-02", child: Text("فبراير")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: importExcel,
                  child: const Text("استيراد"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: exportComparisonPdf,
                  child: const Text("📊 مباينة PDF"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🟢 الإدخال
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [

                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "الاسم")),
                    TextField(controller: numberController, decoration: const InputDecoration(labelText: "الرقم")),
                    TextField(controller: rankController, decoration: const InputDecoration(labelText: "الرتبة")),
                    TextField(controller: unitController, decoration: const InputDecoration(labelText: "الوحدة")),
                    TextField(controller: statusController, decoration: const InputDecoration(labelText: "الحالة")),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        ElevatedButton(
                          onPressed: addPerson,
                          child: const Text("إضافة"),
                        ),

                        ElevatedButton(
                          onPressed: exportExcel,
                          child: const Text("Excel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

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
                      "رقم: ${p["number"]} | رتبة: ${p["rank"]} | شهر: ${p["month"] ?? ""}",
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
