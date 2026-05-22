import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  int totalPeople = 0;
  int totalRecords = 0;
  int totalYears = 0;

  Map<String, int> statusCount = {};

  bool loading = true;

  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  // =========================
  // تحميل الإحصائيات
  // =========================

  Future<void> loadStats() async {

    try {

      final db = await DBHelper.database;

      final people = await db.rawQuery('''
        SELECT COUNT(DISTINCT number) as count
        FROM timeline
      ''');

      final records = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM timeline
      ''');

      final years = await db.rawQuery('''
        SELECT COUNT(DISTINCT year) as count
        FROM timeline
      ''');

      // =========================
      // توزيع الحالات الصحيح
      // =========================

      final statuses = await db.rawQuery('''
        SELECT status, COUNT(*) as count
        FROM timeline
        WHERE status IS NOT NULL
        AND TRIM(status) != ''
        AND status != '-'
        GROUP BY status
        ORDER BY count DESC
      ''');

      Map<String, int> statusMap = {};

      for (var s in statuses) {

        final key =
            s['status'].toString().trim();

        final value =
            int.tryParse(
                  s['count'].toString(),
                ) ??
                0;

        if (key.isNotEmpty) {
          statusMap[key] = value;
        }
      }

      if (!mounted) return;

      setState(() {

        totalPeople =
            int.tryParse(
                  people.first['count'].toString(),
                ) ??
                0;

        totalRecords =
            int.tryParse(
                  records.first['count'].toString(),
                ) ??
                0;

        totalYears =
            int.tryParse(
                  years.first['count'].toString(),
                ) ??
                0;

        statusCount = statusMap;

        loading = false;
      });

    } catch (e) {

      debugPrint(
        "DASHBOARD ERROR: $e",
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // =========================
  // البحث المباشر
  // =========================

  Future<void> searchPeople(
      String value) async {

    final db = await DBHelper.database;

    if (value.trim().isEmpty) {

      setState(() {
        searchResults = [];
      });

      return;
    }

    final data = await db.query(
      'timeline',
      where:
          'number LIKE ? OR name LIKE ?',
      whereArgs: [
        '%$value%',
        '%$value%',
      ],
      limit: 30,
    );

    setState(() {
      searchResults = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "لوحة التحكم",
        ),
        centerTitle: true,
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children: [

                  // =========================
                  // الإحصائيات
                  // =========================

                  Row(
                    children: [

                      Expanded(
                        child: _card(
                          "الأفراد",
                          totalPeople,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _card(
                          "السجلات",
                          totalRecords,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _card(
                    "السنوات المسجلة",
                    totalYears,
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // البحث المباشر
                  // =========================

                  TextField(
                    controller:
                        searchController,

                    decoration:
                        const InputDecoration(
                      labelText:
                          "بحث بالاسم أو الرقم العسكري",
                      border:
                          OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.search),
                    ),

                    onChanged: (value) {
                      searchPeople(value);
                    },
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // نتائج البحث
                  // =========================

                  if (searchResults.isNotEmpty)

                    Container(
                      height: 220,

                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      child: ListView.builder(

                        itemCount:
                            searchResults.length,

                        itemBuilder:
                            (context, index) {

                          final item =
                              searchResults[index];

                          return ListTile(

                            title: Text(
                              item['name']
                                      ?.toString() ??
                                  '',
                            ),

                            subtitle: Text(
                              "الرقم: ${item['number']}",
                            ),

                            trailing: Text(
                              item['status']
                                      ?.toString() ??
                                  '',
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                  // =========================
                  // توزيع الحالات
                  // =========================

                  const Align(
                    alignment:
                        Alignment.centerRight,

                    child: Text(
                      "توزيع الحالات",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: GridView.builder(

                      itemCount:
                          statusCount.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(

                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2,
                      ),

                      itemBuilder:
                          (context, index) {

                        final key =
                            statusCount.keys
                                .elementAt(index);

                        final value =
                            statusCount[key]!;

                        return Container(

                          decoration: BoxDecoration(
                            color:
                                Colors.blue.shade50,

                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),

                            border: Border.all(
                              color:
                                  Colors.blueGrey,
                            ),
                          ),

                          child: Center(
                            child: Column(

                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,

                              children: [

                                Text(
                                  key,

                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                Text(
                                  value.toString(),

                                  style:
                                      const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
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

  // =========================
  // كروت الإحصائيات
  // =========================

  Widget _card(
      String title,
      int value,
      ) {

    return Card(

      elevation: 3,

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            Text(
              title,

              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              value.toString(),

              style: const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
