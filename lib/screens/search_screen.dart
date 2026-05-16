import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> results = [];
  bool loading = false;

  Future<void> searchData(String value) async {

    setState(() {
      loading = true;
    });

    final db = await DBHelper.database;

    final data = await db.query(
      'timeline',
      where: 'number LIKE ? OR name LIKE ?',
      whereArgs: ['%$value%', '%$value%'],
    );

    setState(() {
      results = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            // 🔍 مربع البحث
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'ابحث بالرقم أو الاسم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    results = [];
                  });
                } else {
                  searchData(value);
                }
              },
            ),

            const SizedBox(height: 10),

            if (loading)
              const LinearProgressIndicator(),

            const SizedBox(height: 10),

            // 📋 النتائج
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text('لا توجد نتائج'),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {

                        final item = results[index];

                        return Card(
                          child: ListTile(
                            title: Text(item['name'] ?? ''),
                            subtitle: Text('الرقم: ${item['number']}'),
                            trailing: Text(item['rank'] ?? ''),
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
