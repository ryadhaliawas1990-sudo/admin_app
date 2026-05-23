import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'hr_screen.dart';
import 'reports_archive_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  final List<Widget> screens = [
    const DashboardScreen(),
    const HrScreen(),
    const ReportsArchiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نظام الإدارة"),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text("تصميم رياض عواس"),
              accountEmail: Text("781927044"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person),
              ),
            ),

            _item(Icons.dashboard, "لوحة التحكم", 0),
            _item(Icons.people, "الموارد البشرية", 1),
            _item(Icons.bar_chart, "التقارير", 2),

            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("v1.0 - HR System"),
            ),
          ],
        ),
      ),

      body: screens[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "الموارد",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "التقارير",
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, int i) {
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
