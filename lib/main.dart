import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NumberApp(),
    );
  }
}

class NumberApp extends StatefulWidget {
  const NumberApp({super.key});

  @override
  State<NumberApp> createState() => _NumberAppState();
}

class _NumberAppState extends State<NumberApp> {
  String number = "";

  final TextEditingController controller = TextEditingController();

  void updateNumber() {
    setState(() {
      number = controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تطبيق الأرقام"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "اكتب الرقم هنا",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateNumber,
              child: const Text("عرض الرقم"),
            ),
            const SizedBox(height: 30),
            Text(
              "الرقم: $number",
              style: const TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}
