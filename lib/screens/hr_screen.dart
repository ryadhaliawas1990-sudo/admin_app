import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import '../db/db_helper.dart';
import '../services/excel_to_db_service.dart';
import 'follow_up_screen.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});
  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  // متغيرات الفلاتر والاستيراد
  String importYear = "2026", importMonth = "1", fromYear = "2026", toYear = "2026", fromMonth = "1", toMonth = "12";
  bool isImporting = false;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  final List<String> years = List.generate(12, (i) => (2019 + i).toString());
  final List<String> months = List.generate(12, (i) => (i + 1).toString());

  // دالة البحث
  Future<void> _searchData() async {
    final db = await DBHelper.database;
    final results = await db.query('timeline', where: 'name LIKE ? OR number LIKE ?', whereArgs: ['%${searchController.text}%', '%${searchController.text}%']);
    setState(() => searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الموارد البشرية"), actions: [
        IconButton(icon: const Icon(Icons.list_alt), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowUpScreen())))
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. البحث
          TextField(controller: searchController, decoration: InputDecoration(labelText: "بحث بالاسم أو الرقم", suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _searchData))),
          SizedBox(height: 200, child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, i) => ListTile(title: Text(searchResults[i]['name']), subtitle: Text("رقم: ${searchResults[i]['number']}"), trailing: IconButton(icon: const Icon(Icons.note_add), onPressed: () => /* هنا ضع استدعاء دالة الملاحظة */ null)),
          )),
          const Divider(),
          // 2. الاستيراد والأشهر
          _buildSectionTitle("📥 استيراد كشوفات الأفراد"),
          _buildImportCard(),
          // 3. الفلاتر والتقرير
          _buildSectionTitle("📊 إنشاء تقرير كتلي"),
          _buildReportFilters(),
          ElevatedButton(onPressed: () {}, child: const Text("تصدير التقرير")),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)));
  
  Widget _buildImportCard() => Card(child: Column(children: [Row(children: [Expanded(child: DropdownButtonFormField<String>(value: importYear, items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setState(() => importYear = v!))), Expanded(child: DropdownButtonFormField<String>(value: importMonth, items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => importMonth = v!)))])]));

  Widget _buildReportFilters() => Column(children: [Row(children: [Expanded(child: DropdownButtonFormField<String>(value: fromYear, decoration: const InputDecoration(labelText: "من سنة"), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setState(() => fromYear = v!))), Expanded(child: DropdownButtonFormField<String>(value: toYear, decoration: const InputDecoration(labelText: "إلى سنة"), items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(), onChanged: (v) => setState(() => toYear = v!)))])]);
}
