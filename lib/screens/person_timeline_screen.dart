import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class PersonTimelineScreen extends StatefulWidget {
  final String number;

  const PersonTimelineScreen({
    super.key,
    required this.number,
  });

  @override
  State<PersonTimelineScreen> createState() => _PersonTimelineScreenState();
}

class _PersonTimelineScreenState extends State<PersonTimelineScreen> {
  List<Map<String, dynamic>> timeline = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await DBHelper.getPersonTimeline(widget.number);

      setState(() {
        timeline = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("السجل التاريخي للفرد"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : timeline.isEmpty
              ? const Center(child: Text("لا توجد بيانات"))
              : ListView.builder(
                  itemCount: timeline.length,
                  itemBuilder: (context, index) {
                    final item = timeline[index];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          "${item['name'] ?? ''} - ${item['rank'] ?? ''}",
                        ),
                        subtitle: Text(
                          "شهر: ${item['month']} / سنة: ${item['year']}\n"
                          "الحالة: ${item['status'] ?? ''}",
                        ),
                        trailing: Text(item['unit'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
