import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نظام الإدارة والسيطرة العام"),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2, // تقسيم الشاشة لبطاقات متوازية
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              // 1. قطاع الموارد البشرية (مستقل)
              _buildMenuCard(
                context,
                title: "الموارد البشرية",
                subtitle: "سجل الحالة والمباينات",
                icon: Icons.people_alt,
                color: Colors.blue.shade700,
                route: '/hr',
              ),

              // 2. قطاع الفنية والتسليح (مستقل)
              _buildMenuCard(
                context,
                title: "الفنية والتسليح",
                subtitle: "الآليات، قطع الغيار والمشتريات",
                icon: Icons.settings_suggest,
                color: Colors.orange.shade800,
                route: '/technical',
              ),

              // 3. قطاع الإمداد والتموين (مستقل)
              _buildMenuCard(
                context,
                title: "الإمداد والتموين",
                subtitle: "الغذاء، المحروقات والإسكان",
                icon: Icons.local_shipping,
                color: Colors.purple.shade700,
                route: '/supply',
              ),

              // 4. قطاع التقارير والإحصائيات
              _buildMenuCard(
                context,
                title: "التقارير العامة",
                subtitle: "الأرشيف والمخرجات",
                icon: Icons.bar_chart,
                color: Colors.teal.shade700,
                route: '/reports',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
