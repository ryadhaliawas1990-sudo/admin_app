import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class PersonTimelineScreen extends StatefulWidget {

  final String number;
  final String name;

  const PersonTimelineScreen({
    super.key,
    required this.number,
    required this.name,
  });

  @override
  State<PersonTimelineScreen> createState() => _PersonTimelineScreenState();
}

class _PersonTimelineScreenState extends State<PersonTimelineScreen> {

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await DBHelper.getPersonTimeline(widget.number);

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),

      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {

          final item = data[index];

          return ListTile(
            title: Text("${item['year']} - ${item['month']}"),
            subtitle: Text("الحالة: ${item['status']}"),
            trailing: Text(item['unit'] ?? ''),
          );
        },
      ),
    );
  }
}
