import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import 'import_screen.dart';
import 'person_timeline_screen.dart';

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

    final data = await DBHelper.getAllTimeline();

    setState(() {
      people = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('سجل الحالة'),

        actions: [

          IconButton(
            icon: const Icon(Icons.upload_file),

            onPressed: () async {

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImportScreen(),
                ),
              );

              // تحديث بعد الاستيراد
              loadData();
            },
          ),
        ],
      ),

      body: people.isEmpty

          ? const Center(
              child: Text('لا توجد بيانات'),
            )

          : ListView.builder(

              itemCount: people.length,

              itemBuilder: (context, index) {

                final item = people[index];

                return Card(

                  child: ListTile(

                    title: Text(
                      item['name'] ?? '',
                    ),

                    subtitle: Text(
                      'الرقم: ${item['number']}',
                    ),

                    trailing: Text(
                      item['rank'] ?? '',
                    ),

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PersonTimelineScreen(
                            number: item['number'] ?? '',
                            name: item['name'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
