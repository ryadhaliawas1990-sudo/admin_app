import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'hr_screen.dart';
import 'reports_archive_screen.dart';
import 'comparison_builder_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  final screens = const [
    DashboardScreen(),
    HrScreen(),
    ReportsArchiveScreen(),
    const HrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نظام الإدارة"),
      ),

      // 🧭 القائمة الجانبية الاحترافية
      drawer: Drawer(
        child: Column(
          children: [

            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),

              accountName: const Text(
                "تصميم رياض عواس",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              accountEmail: const Text(
                "781927044",
              ),

              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("لوحة التحكم"),
              onTap: () {
                setState(() => index = 0);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("الموارد البشرية"),
              onTap: () {
                setState(() => index = 1);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("التقارير"),
              onTap: () {
                setState(() => index = 2);
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text("المباينة"),
              onTap: () {
                setState(() => index = 3);
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "v1.0 - HR System",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),

      body: screens[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
          });
        },
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: "المباينة",
          ),
        ],
      ),
    );
  }
}
