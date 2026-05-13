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
    await DBHelper.insertOrUpdate({
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
      SnackBar(
        content: Text("تم حفظ Excel في: $path"),
      ),
    );
  }

  Future<void> importExcel() async {
    await ExcelImport.pickAndImport(selectedMonth);
    loadData();
  }

  // ✅ تصدير PDF النهائي
  Future<void> exportComparisonPdf() async {

    await MonthlyComparisonPdf.export(

      months: [
        "2026-01",
        "2026-02",
        "2026-03",
      ],

      people: people,

      data: {
        for (var p in people)
          p["number"]: {
            "months": {
              "2026-01": p["status"] ?? "-",
              "2026-02": p["status"] ?? "-",
              "2026-03": p["status"] ?? "-",
            }
          }
      },

      topText: "تقرير المباينة النهائي",

      leftSignature: "القائد",

      rightSignature: "شؤون الأفراد",
    );
  }

  void _clearInputs() {
    nameController.clear();
    numberController.clear();
    rankController.clear();
    statusController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("HR"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: exportComparisonPdf,
                    child: const Text("PDF"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: exportExcel,
                    child: const Text("Excel"),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {

                final p = people[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),

                    title: Text(
                      p["name"] ?? "",
                    ),

                    subtitle: Text(
                      "رقم: ${p["number"]} | ${p["unit"]}",
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deletePerson(p["id"]);
                      },
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
