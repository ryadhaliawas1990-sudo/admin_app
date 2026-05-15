import 'package:flutter/material.dart';

class ComparisonResultScreen extends StatelessWidget {

  final List<Map<String, dynamic>> changed;
  final List<Map<String, dynamic>> missing;
  final List<Map<String, dynamic>> added;

  const ComparisonResultScreen({
    super.key,
    required this.changed,
    required this.missing,
    required this.added,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("نتائج المقارنة"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),

        children: [

          _sectionTitle("🔴 تم تغييره"),
          ...changed.map((item) => _card(
            item["number"],
            item["name"],
            "من: ${item["old"]} ➜ إلى: ${item["new"]}",
          )),

          const SizedBox(height: 20),

          _sectionTitle("⚠️ مفقود"),
          ...missing.map((item) => _card(
            item["number"],
            item["name"],
            "غير موجود في الملف الجديد",
          )),

          const SizedBox(height: 20),

          _sectionTitle("🟢 جديد"),
          ...added.map((item) => _card(
            item["number"],
            item["name"],
            "موجود فقط في الملف الجديد",
          )),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _card(String number, String name, String subtitle) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(name.isEmpty ? "بدون اسم" : name),
        subtitle: Text("رقم: $number\n$subtitle"),
      ),
    );
  }
}
