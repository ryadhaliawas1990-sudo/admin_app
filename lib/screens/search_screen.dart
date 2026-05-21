import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController controller =
      TextEditingController();

  List<Map<String, dynamic>> results = [];

  bool loading = false;

  Future<void> searchData(String value) async {

    final query = value.trim();

    if (query.isEmpty) {

      setState(() {
        results = [];
        loading = false;
      });

      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final db = await DBHelper.database;

      final data = await db.rawQuery(
        '''
        SELECT * FROM timeline
        WHERE number LIKE ?
        OR name LIKE ?
        ORDER BY year DESC, month DESC
        ''',
        [
          '%$query%',
          '%$query%',
        ],
      );

      if (!mounted) return;

      setState(() {
        results = List<Map<String, dynamic>>.from(data);
        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ أثناء البحث: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('البحث التاريخي'),
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

                if (value.trim().isEmpty) {

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

                          elevation: 2,

                          child: ListTile(

                            leading: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),

                            title: Text(
                              item['name']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  'الرقم: ${item['number'] ?? '-'}',
                                ),

                                Text(
                                  'الحالة: ${item['status'] ?? '-'}',
                                ),

                                Text(
                                  'الوحدة: ${item['unit'] ?? '-'}',
                                ),
                              ],
                            ),

                            trailing: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,

                              children: [

                                Text(
                                  item['rank']?.toString() ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  '${item['month']}/${item['year']}',
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
      ),
    );
  }
}
