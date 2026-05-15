import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'person_timeline_screen.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await DBHelper.insertTestData(); // للتجربة فقط

    final result = await DBHelper.getAllTimeline();

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("الأفراد")),

      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {

          final item = data[index];

          return ListTile(
            title: Text(item['name'] ?? ''),
            subtitle: Text(item['number'] ?? ''),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonTimelineScreen(
                    number: item['number'],
                    name: item['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
