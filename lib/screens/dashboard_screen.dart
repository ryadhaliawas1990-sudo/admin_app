import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =========================
            // مربع البحث
            // =========================

            TextField(
              decoration: InputDecoration(
                hintText: "بحث...",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // بطاقات الإحصائيات
            // =========================

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,

                children: [

                  _buildCard(
                    title: "إجمالي الأفراد",
                    value: "1250",
                    icon: Icons.people,
                    color: Colors.blue,
                  ),

                  _buildCard(
                    title: "الحضور اليوم",
                    value: "980",
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),

                  _buildCard(
                    title: "الغياب",
                    value: "45",
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),

                  _buildCard(
                    title: "التقارير",
                    value: "32",
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Container(

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 40,
              color: color,
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
