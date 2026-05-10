import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/excel_export.dart';

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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DBHelper.getPeople();

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
    });

    nameController.clear();
    numberController.clear();
    rankController.clear();
    unitController.clear();
    statusController.clear();

    loadData();
  }

  Future<void> exportExcel() async {
    final path = await ExcelExport.exportToExcel(people);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم حفظ Excel في: $path"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الموارد البشرية"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "اسم الضابط / الفرد",
              ),
            ),

            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: "رقم الضابط / الفرد",
              ),
            ),

            TextField(
              controller: rankController,
              decoration: const InputDecoration(
                labelText: "الرتبة",
              ),
            ),

            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: "الوحدة",
              ),
            ),

            TextField(
              controller: statusController,
              decoration: const InputDecoration(
                labelText: "الحالة",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addPerson,
              child: const Text("إضافة وحفظ"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: exportExcel,
              child: const Text("تصدير Excel"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: people.length,
                itemBuilder: (context, index) {
                  final p = people[index];

                  return Card(
                    child: ListTile(
                      title: Text(p["name"] ?? ""),
                      subtitle: Text(
                        "رقم: ${p["number"]} | رتبة: ${p["rank"]} | وحدة: ${p["unit"]} | حالة: ${p["status"]}",
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
