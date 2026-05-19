import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'reports_archive_screen.dart';
import 'hr_screen.dart';
import 'comparison_screen.dart'; // تأكدنا من وجود هذا الملف

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  // الربط الصحيح: كل صفحة بملفها الخاص
  final List<Widget> screens = const [
    DashboardScreen(),
    HrScreen(),
    ReportsArchiveScreen(),
    ComparisonScreen(), // الآن المباينة لها شاشتها الخاصة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("نظام الإدارة")),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text("تصميم رياض عواس", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text("781927044"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.blue)),
            ),
            _buildDrawerItem(Icons.dashboard, "لوحة التحكم", 0),
            _buildDrawerItem(Icons.people, "الموارد البشرية", 1),
            _buildDrawerItem(Icons.bar_chart, "التقارير", 2),
            _buildDrawerItem(Icons.compare_arrows, "المباينة", 3),
            const Spacer(),
            const Padding(padding: EdgeInsets.all(12), child: Text("v1.0 - HR System", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "الموارد"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "التقارير"),
          BottomNavigationBarItem(icon: Icon(Icons.compare_arrows), label: "المباينة"),
        ],
      ),
    );
  }

  // دالة مساعدة لجعل الكود أنظف وأقل عرضة للخطأ
  Widget _buildDrawerItem(IconData icon, String title, int i) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        setState(() => index = i);
        Navigator.pop(context);
      },
    );
  }
}
