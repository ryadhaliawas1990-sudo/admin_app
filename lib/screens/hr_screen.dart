import 'package:flutter/material.dart';

import '../data/excel_import.dart';
import '../export/comparison_excel_export.dart';

class HrScreen extends StatefulWidget {

  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {

  final monthController =
      TextEditingController();

  final oldMonthController =
      TextEditingController();

  final newMonthController =
      TextEditingController();

  String message = '';

  // استيراد ملف شهر
  Future<void> importMonth() async {

    if (monthController.text.isEmpty) {
      return;
    }

    await ExcelImport.pickAndImport(
      monthController.text,
    );

    setState(() {

      message =
          'تم استيراد شهر ${monthController.text}';
    });
  }

  // مقارنة شهرين
  Future<void> compareMonths() async {

    if (oldMonthController.text.isEmpty ||
        newMonthController.text.isEmpty) {
      return;
    }

    final path =
        await ComparisonExcelExport.exportComparison(

      oldMonthController.text,

      newMonthController.text,
    );

    setState(() {

      message =
          'تم إنشاء ملف المقارنة:\n$path';
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'نظام المباينة',
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: ListView(

          children: [

            const Text(
              'استيراد ملف Excel',
            ),

            const SizedBox(height: 10),

            TextField(

              controller: monthController,

              decoration: const InputDecoration(

                border: OutlineInputBorder(),

                labelText:
                    'أدخل الشهر مثال 2026-01',
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(

              onPressed: importMonth,

              child: const Text(
                'استيراد الملف',
              ),
            ),

            const Divider(height: 40),

            const Text(
              'مقارنة شهرين',
            ),

            const SizedBox(height: 10),

            TextField(

              controller: oldMonthController,

              decoration: const InputDecoration(

                border: OutlineInputBorder(),

                labelText:
                    'الشهر القديم',
              ),
            ),

            const SizedBox(height: 10),

            TextField(

              controller: newMonthController,

              decoration: const InputDecoration(

                border: OutlineInputBorder(),

                labelText:
                    'الشهر الجديد',
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(

              onPressed: compareMonths,

              child: const Text(
                'تشغيل المقارنة',
              ),
            ),

            const SizedBox(height: 30),

            Text(
              message,
            ),
          ],
        ),
      ),
    );
  }
}
