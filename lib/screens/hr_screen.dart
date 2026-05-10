import 'package:flutter/material.dart';

class HrScreen extends StatelessWidget {
  const HrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الموارد البشرية")),
      body: const Center(
        child: Text(
          "واجهة الموارد البشرية جاهزة",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
