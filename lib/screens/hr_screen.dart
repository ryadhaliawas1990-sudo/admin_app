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
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  // دالة البحث
  Future<void> _searchData() async {
    final db = await DBHelper.database;
    final query = searchController.text.trim();
    final results = await db.query('timeline', 
      where: 'name LIKE ? OR number LIKE ?', 
      whereArgs: ['%$query%', '%$query%']
    );
    setState(() => searchResults = results);
  }

  // إضافة الملاحظة
  void _showAddNoteDialog(Map<String, dynamic> person) {
    TextEditingController noteController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("ملاحظة لـ ${person['name']}"),
      content: TextField(controller: noteController, decoration: const InputDecoration(hintText: "اكتب الملاحظة...")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
        ElevatedButton(onPressed: () async {
          await DBHelper.addNote(person['number'].toString(), person['month'].toString(), person['year'].toString(), noteController.text);
          if(!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ الملاحظة")));
        }, child: const Text("حفظ"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الموارد البشرية"), actions: [
        IconButton(icon: const Icon(Icons.list_alt), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowUpScreen())))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // مربع البحث
          TextField(controller: searchController, decoration: const InputDecoration(labelText: "بحث بالاسم أو الرقم", suffixIcon: IconButton(icon: Icon(Icons.search), onPressed: _searchData))),
          const SizedBox(height: 10),
          Expanded(child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(searchResults[i]['name']),
              subtitle: Text("رقم: ${searchResults[i]['number']} - حالة: ${searchResults[i]['status']}"),
              trailing: IconButton(icon: const Icon(Icons.note_add, color: Colors.blue), onPressed: () => _showAddNoteDialog(searchResults[i])),
            )
          ))
        ]),
      ),
    );
  }
  // (باقي الدوال: _buildImportCard, _generateFilteredReport تبقى كما هي في الكود السابق)
}
