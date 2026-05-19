import 'package:flutter/material.dart';

// 🚀 حقن مسار شاشة الإدارة اليدوية للأفراد الجديدة
import 'manage_individual_screen.dart';

import 'hr_screen.dart';
import 'report_screen.dart';
import 'dashboard_screen.dart';
import 'export_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("النظام الإداري العام"),
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
            "لوحة التحكم",
            Icons.dashboard,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
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

          _card(
            context,
            "تصدير Excel",
            Icons.download,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              );
            },
          ),

          // 🪖 المربع الخامس الجديد: الإدارة اليدوية والأرشفة
          _card(
            context,
            "الإدارة اليدوية للأفراد",
            Icons.person_add,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageIndividualScreen()),
              );
            },
            cardColor: Colors.blue.shade50, // تمييز بسيط للزر الجديد لسهولة الوصول
          ),
        ],
      ),
    );
  }

  // دالة بناء المربعات المحدثة لتقبل ألواناً مخصصة اختيارياً
  Widget _card(BuildContext context, String title, IconData icon, VoidCallback onTap, {Color? cardColor}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: cardColor,
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: cardColor != null ? Colors.blue.shade900 : null),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: cardColor != null ? FontWeight.bold : FontWeight.normal,
                  color: cardColor != null ? Colors.blue.shade900 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
