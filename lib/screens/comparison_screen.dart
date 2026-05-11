import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../export/monthly_comparison_pdf.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() =>
      _ComparisonScreenState();
}

class _ComparisonScreenState
    extends State<ComparisonScreen> {

  // 📅 الأشهر الديناميكية
  List<String> months = [];

  String monthA = "";
  String monthB = "";

  // 🔎 البحث
  String searchQuery = "";

  // 📊 النتائج
  List<Map<String, dynamic>> added = [];
  List<Map<String, dynamic>> removed = [];
  List<Map<String, dynamic>> stable = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadMonths();
  }

  // 📅 تحميل الأشهر من قاعدة البيانات
  Future<void> loadMonths() async {

    final data = await DBHelper.getPeople();

    final extractedMonths = data
        .map((e) => e["month"]?.toString() ?? "")
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();

    extractedMonths.sort();

    setState(() {

      months = extractedMonths;

      if (months.isNotEmpty) {

        monthA = months.first;

        if (months.length > 1) {
          monthB = months.last;
        } else {
          monthB = months.first;
        }
      }
    });
  }

  // 📊 المقارنة
  Future<void> compare() async {

    if (monthA.isEmpty || monthB.isEmpty) {
      return;
    }

    setState(() => loading = true);

    final a = await DBHelper.getByMonth(monthA);
    final b = await DBHelper.getByMonth(monthB);

    final mapA = {
      for (var e in a) e["number"]: e
    };

    final mapB = {
      for (var e in b) e["number"]: e
    };

    added.clear();
    removed.clear();
    stable.clear();

    // 🟡 دخل جديد
    for (var key in mapB.keys) {

      if (!mapA.containsKey(key)) {
        added.add(mapB[key]!);
      }
    }

    // 🔴 خرج
    for (var key in mapA.keys) {

      if (!mapB.containsKey(key)) {
        removed.add(mapA[key]!);
      }
    }

    // 🟢 ثابت
    for (var key in mapA.keys) {

      if (mapB.containsKey(key)) {
        stable.add(mapA[key]!);
      }
    }

    setState(() => loading = false);
  }

  // 📄 تصدير PDF
  Future<void> exportPdf() async {

    await MonthlyComparisonPdf.export([
      monthA,
      monthB,
    ]);
  }

  // 🔎 فلترة القوائم
  List<Map<String, dynamic>> filterList(
    List<Map<String, dynamic>> list,
  ) {

    if (searchQuery.isEmpty) {
      return list;
    }

    return list.where((p) {

      final name =
          (p["name"] ?? "").toString();

      final number =
          (p["number"] ?? "").toString();

      return name.contains(searchQuery) ||
          number.contains(searchQuery);

    }).toList();
  }

  // 📋 بناء القوائم
  Widget buildList(
    String title,
    List<Map<String, dynamic>> list,
    Color color,
  ) {

    final filtered = filterList(list);

    return Expanded(
      child: Card(
        elevation: 4,

        child: Column(
          children: [

            Container(
              width: double.infinity,
              color: color,
              padding: const EdgeInsets.all(10),

              child: Text(
                "$title (${filtered.length})",

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text("لا توجد بيانات"),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,

                      itemBuilder: (context, index) {

                        final p = filtered[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),

                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),

                            title: Text(
                              p["name"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "الرقم: ${p["number"]}",
                                ),

                                Text(
                                  "الرتبة: ${p["rank"] ?? ""}",
                                ),

                                Text(
                                  "الوحدة: ${p["unit"] ?? ""}",
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("نظام المقارنة الذكي"),
        centerTitle: true,
        backgroundColor: Colors.blue,

        actions: const [

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),

            child: Center(
              child: Text(
                "تصميم: م/رياض عواس",
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          // 🔎 البحث
          Padding(
            padding: const EdgeInsets.all(10),

            child: TextField(
              decoration: const InputDecoration(
                labelText: "بحث بالاسم أو الرقم",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),

              onChanged: (value) {

                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // 🎛️ لوحة التحكم
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),

            child: Card(
              elevation: 5,

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  children: [

                    // 📅 اختيار الأشهر
                    Row(
                      children: [

                        const Text(
                          "من:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: DropdownButton<String>(
                            value: monthA.isEmpty
                                ? null
                                : monthA,

                            isExpanded: true,

                            hint: const Text(
                              "اختر الشهر",
                            ),

                            items: months.map((m) {

                              return DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              );
                            }).toList(),

                            onChanged: (v) {

                              setState(() {
                                monthA = v!;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 15),

                        const Text(
                          "إلى:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: DropdownButton<String>(
                            value: monthB.isEmpty
                                ? null
                                : monthB,

                            isExpanded: true,

                            hint: const Text(
                              "اختر الشهر",
                            ),

                            items: months.map((m) {

                              return DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              );
                            }).toList(),

                            onChanged: (v) {

                              setState(() {
                                monthB = v!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // 📊 الأزرار
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,

                      children: [

                        ElevatedButton.icon(
                          onPressed: compare,

                          icon: const Icon(
                            Icons.compare_arrows,
                          ),

                          label: const Text(
                            "تنفيذ المقارنة",
                          ),
                        ),

                        ElevatedButton.icon(
                          onPressed: exportPdf,

                          icon: const Icon(
                            Icons.picture_as_pdf,
                          ),

                          label: const Text(
                            "تصدير PDF",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ⏳ تحميل
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),

          // 📊 النتائج
          if (!loading)
            Expanded(
              child: Column(
                children: [

                  // 🟡 + 🔴
                  Expanded(
                    child: Row(
                      children: [

                        buildList(
                          "🟡 دخل جديد",
                          added,
                          Colors.green,
                        ),

                        buildList(
                          "🔴 خرج",
                          removed,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),

                  // 🟢
                  Expanded(
                    child: buildList(
                      "🟢 ثابت",
                      stable,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
