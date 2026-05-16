import 'dart:async';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class LiveSearchScreen extends StatefulWidget {
  const LiveSearchScreen({super.key});

  @override
  State<LiveSearchScreen> createState() => _LiveSearchScreenState();
}

class _LiveSearchScreenState extends State<LiveSearchScreen> {

  List<Map<String, dynamic>> results = [];
  final TextEditingController controller = TextEditingController();

  Timer? _debounce;

  String? selectedMonth;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final data = await DBHelper.getTimelinePaged(
      limit: 20,
      offset: 0,
    );

    setState(() {
      results = data;
    });
  }

  void onSearchChanged(String value) {

    // ⛔ إلغاء البحث السابق
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // ⏳ انتظار قبل التنفيذ
    _debounce = Timer(const Duration(milliseconds: 400), () async {

      final data = await DBHelper.advancedSearch(
        query: value,
        month: selectedMonth,
        status: selectedStatus,
      );

      setState(() {
        results = data;
      });
    });
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
      appBar: AppBar(title: const Text("بحث فوري")),

      body: Column(
        children: [

          // 🔍 البحث الفوري
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                labelText: "ابحث الآن...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 📋 النتائج
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text("لا توجد نتائج"))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {

                      final item = results[index];

                      return ListTile(
                        title: Text(item['name'] ?? ''),
                        subtitle: Text(
                          "رقم: ${item['number']} | رتبة: ${item['rank']}",
                        ),
                        trailing: Text(item['status'] ?? ''),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
