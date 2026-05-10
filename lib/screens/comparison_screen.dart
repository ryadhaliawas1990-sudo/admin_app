import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  String monthA = "2026-01";
  String monthB = "2026-02";

  List<Map<String, dynamic>> added = [];
  List<Map<String, dynamic>> removed = [];
  List<Map<String, dynamic>> stable = [];

  bool loading = false;

  Future<void> compare() async {
    setState(() => loading = true);

    final a = await DBHelper.getByMonth(monthA);
    final b = await DBHelper.getByMonth(monthB);

    final mapA = {for (var e in a) e["number"]: e};
    final mapB = {for (var e in b) e["number"]: e};

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

  Widget buildList(String title, List<Map<String, dynamic>> list, Color color) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: color,
              padding: const EdgeInsets.all(8),
              child: Text(
                "$title (${list.length})",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  return ListTile(
                    title: Text(p["name"] ?? ""),
                    subtitle: Text("رقم: ${p["number"]}"),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مقارنة الأشهر"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // 🎛️ Controls
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                DropdownButton(
                  value: monthA,
                  items: const [
                    DropdownMenuItem(value: "2026-01", child: Text("يناير")),
                    DropdownMenuItem(value: "2026-02", child: Text("فبراير")),
                  ],
                  onChanged: (v) => setState(() => monthA = v!),
                ),

                const SizedBox(width: 10),

                DropdownButton(
                  value: monthB,
                  items: const [
                    DropdownMenuItem(value: "2026-01", child: Text("يناير")),
                    DropdownMenuItem(value: "2026-02", child: Text("فبراير")),
                  ],
                  onChanged: (v) => setState(() => monthB = v!),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: compare,
                  child: const Text("مقارنة"),
                ),
              ],
            ),
          ),

          if (loading) const CircularProgressIndicator(),

          if (!loading)
            Expanded(
              child: Column(
                children: [

                  Expanded(
                    child: Row(
                      children: [
                        buildList("🟡 دخل جديد", added, Colors.green),
                        buildList("🔴 خرج", removed, Colors.red),
                      ],
                    ),
                  ),

                  Expanded(
                    child: buildList("🟢 ثابت", stable, Colors.blue),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
