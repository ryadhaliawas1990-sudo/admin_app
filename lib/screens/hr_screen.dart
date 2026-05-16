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
  List<Map<String, dynamic>> filtered = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DBHelper.getAllTimeline();

    setState(() {
      people = data;
      filtered = data;
    });
  }

  void search(String value) {

    if (value.isEmpty) {
      setState(() {
        filtered = people;
      });
      return;
    }

    final result = people.where((item) {

      final name = item['name'].toString();
      final number = item['number'].toString();

      return name.contains(value) || number.contains(value);

    }).toList();

    setState(() {
      filtered = result;
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

              loadData();
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // 🔍 البحث
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'بحث بالاسم أو الرقم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: search,
            ),
          ),

          const SizedBox(height: 5),

          // 📋 القائمة
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('لا توجد بيانات'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {

                      final item = filtered[index];

                      return Card(
                        child: ListTile(
                          title: Text(item['name'] ?? ''),
                          subtitle: Text('الرقم: ${item['number']}'),
                          trailing: Text(item['rank'] ?? ''),
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
          ),
        ],
      ),
    );
  }
}
