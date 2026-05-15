import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class PersonTimelineScreen extends StatefulWidget {
  const PersonTimelineScreen({super.key});

  @override
  State<PersonTimelineScreen> createState() => _PersonTimelineScreenState();
}

class _PersonTimelineScreenState extends State<PersonTimelineScreen> {

  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> data = [];

  bool loading = false;

  Future<void> search() async {

    setState(() {
      loading = true;
      data = [];
    });

    final result =
        await DBHelper.searchPersonTimeline(controller.text);

    setState(() {
      data = result;
      loading = false;
    });
  }

  String getName() {
    return data.isNotEmpty ? data.first['name'] ?? '' : '';
  }

  String getNumber() {
    return data.isNotEmpty ? data.first['number'] ?? '' : '';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("ملف الفرد الزمني"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // =====================
            // بحث
            // =====================
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "رقم عسكري أو اسم",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : search,
                child: const Text("عرض الملف"),
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // بيانات أعلى الجدول
            // =====================
            if (data.isNotEmpty) ...[
              Text(
                "الاسم: ${getName()}",
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "الرقم: ${getNumber()}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
            ],

            const Divider(),

            // =====================
            // الجدول الزمني
            // =====================
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : data.isEmpty
                      ? const Center(
                          child: Text("لا توجد بيانات"),
                        )
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {

                            final item = data[index];

                            return Card(
                              child: ListTile(
                                title: Text(
                                  "${item['month']} / ${item['year']}",
                                ),
                                subtitle: Text(
                                  "الحالة: ${item['status']} | الوحدة: ${item['unit']}",
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
}
