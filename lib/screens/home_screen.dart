// أضف هذا السطر في أعلى ملف شاشتك الرئيسية للاستدعاء
import 'manage_individual_screen.dart';

// داخل الـ Build الخاص بالشاشة الرئيسية، في قائمة الأزرار أو الـ Drawer، أضف هذا الزر التلقائي:
ListTile(
  leading: const Icon(Icons.person_add, color: Colors.blue),
  title: const Text('الإدارة اليدوية للأفراد', style: TextStyle(fontWeight: FontWeight.bold)),
  subtitle: const Text('إضافة فرد، تعديل رتبة، أو تغيير حالة يدوياً'),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageIndividualScreen()),
    );
  },
)

import 'package:flutter/material.dart';

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
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45),
              const SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
