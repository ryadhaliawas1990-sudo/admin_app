import 'package:flutter/material.dart';
import 'hr_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("النظام الإداري"),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        children: [

          _card(
            context,
            "الموارد البشرية",
            Icons.people,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HrScreen()),
              );
            },
          ),

          _card(
            context,
            "التقارير",
            Icons.bar_chart,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50),
              const SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
