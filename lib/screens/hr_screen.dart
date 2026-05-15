import 'package:flutter/material.dart';
import '../features/excel_compare/compare_two_files.dart';
import '../db/db_helper.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {

  List<Map<String, dynamic>> people = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DBHelper.getAllTimeline():

    if (!mounted) return;

    setState(() {
      people = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("HR System"),
      ),

      body: Column(
        children: [

          const SizedBox(height: 20),

          // =========================
          // زر المقارنة
          // =========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  await CompareTwoFiles.run(context);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تشغيل المقارنة بنجاح'),
                    ),
                  );
                },
                child: const Text("تشغيل مقارنة ملفين Excel"),
              ),
            ),
          ),

          const Divider(),

          // =========================
          // عرض البيانات (اختياري)
          // =========================
          Expanded(
            child: ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {

                final p = people[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(p["name"] ?? ""),
                  subtitle: Text("رقم: ${p["number"] ?? ""}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
