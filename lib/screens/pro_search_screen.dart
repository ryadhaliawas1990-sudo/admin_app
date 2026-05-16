import 'dart:async';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ProSearchScreen extends StatefulWidget {
  const ProSearchScreen({super.key});

  @override
  State<ProSearchScreen> createState() => _ProSearchScreenState();
}

class _ProSearchScreenState extends State<ProSearchScreen> {

  final TextEditingController controller = TextEditingController();

  Timer? _debounce;

  List<Map<String, dynamic>> results = [];
  List<String> suggestions = [];

  String? selectedMonth;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    loadInitial();
  }

  Future<void> loadInitial() async {
    final data = await DBHelper.getTimelinePaged(limit: 20, offset: 0);

    setState(() {
      results = data;
    });
  }

  // 🔥 بحث احترافي
  void onSearchChanged(String value) {

    // ⛔ إلغاء البحث السابق
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {

      if (value.isEmpty) {
        loadInitial();
        return;
      }

      final data = await DBHelper.advancedSearch(
        query: value,
        month: selectedMonth,
        status: selectedStatus,
      );

      // 🔥 ترتيب ذكي (الأهم أولاً)
      data.sort((a, b) =>
          (b['name'] ?? '').length.compareTo((a['name'] ?? '').length));

      setState(() {
        results = data;

        // 🔥 اقتراحات (أول 5 نتائج)
        suggestions = data
            .take(5)
            .map((e) => e['name'].toString())
            .toList();
      });
    });
  }

  // 🔥 Highlight النص
  TextSpan highlight(String text, String query) {

    if (query.isEmpty) {
      return TextSpan(text: text);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final start = lowerText.indexOf(lowerQuery);

    if (start == -1) {
      return TextSpan(text: text);
    }

    final end = start + query.length;

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: text.substring(start, end),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: text.substring(end)),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("بحث احترافي")),

      body: Column(
        children: [

          // 🔍 البحث
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                labelText: "ابحث (اسم - رقم - رتبة - وحدة)",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 💡 الاقتراحات
          if (suggestions.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: suggestions.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(s),
                      onPressed: () {
                        controller.text = s;
                        onSearchChanged(s);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 5),

          // 📋 النتائج
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text("لا توجد نتائج"))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {

                      final item = results[index];

                      return Card(
                        child: ListTile(

                          title: RichText(
                            text: highlight(
                              item['name'] ?? '',
                              controller.text,
                            ),
                          ),

                          subtitle: Text(
                            "رقم: ${item['number']} | رتبة: ${item['rank']} | وحدة: ${item['unit']}",
                          ),

                          trailing: Text(item['status'] ?? ''),
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
