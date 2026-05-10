import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("التقارير")),
      body: const Center(
        child: Text(
          "واجهة التقارير جاهزة",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
