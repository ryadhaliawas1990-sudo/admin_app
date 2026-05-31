import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class FollowUpScreen extends StatefulWidget {
  const FollowUpScreen({super.key});
  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("سجل المتابعة (الملاحظات)"), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchNotesWithDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("لا توجد ملاحظات مسجلة"));
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("${item['name']} - ${item['number']}"),
                  subtitle: Text("التاريخ: ${item['month']}/${item['year']}\nالملاحظة: ${item['note_text']}"),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchNotesWithDetails() async {
    final db = await DBHelper.database;
    // جلب الملاحظات مع دمجها ببيانات الفرد من جدول timeline
    return await db.rawQuery('''
      SELECT notes.*, timeline.name 
      FROM notes 
      JOIN timeline ON notes.number = timeline.number 
      GROUP BY notes.id
    ''');
  }
}
