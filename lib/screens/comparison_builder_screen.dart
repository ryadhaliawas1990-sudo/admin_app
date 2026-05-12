import 'package:flutter/material.dart';

class ComparisonBuilderScreen extends StatefulWidget {
  const ComparisonBuilderScreen({super.key});

  @override
  State<ComparisonBuilderScreen> createState() =>
      _ComparisonBuilderScreenState();
}

class _ComparisonBuilderScreenState
    extends State<ComparisonBuilderScreen> {

  String name = "أحمد";
  String number = "1001";
  String rank = "جندي";
  String status = "نشط";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("بناء المباينة"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(
                labelText: "الاسم",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => name = v,
            ),

            const SizedBox(height: 10),

            TextFormField(
              initialValue: number,
              decoration: const InputDecoration(
                labelText: "الرقم",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => number = v,
            ),

            const SizedBox(height: 10),

            TextFormField(
              initialValue: rank,
              decoration: const InputDecoration(
                labelText: "الرتبة",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => rank = v,
            ),

            const SizedBox(height: 10),

            TextFormField(
              initialValue: status,
              decoration: const InputDecoration(
                labelText: "الحالة",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => status = v,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم الحفظ")),
                );
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }
}
