import 'package:flutter/material.dart';

import '../features/excel_compare/compare_two_files.dart';

class ExcelCompareScreen extends StatefulWidget {
  const ExcelCompareScreen({super.key});

  @override
  State<ExcelCompareScreen> createState() =>
      _ExcelCompareScreenState();
}

class _ExcelCompareScreenState
    extends State<ExcelCompareScreen> {

  String message = '';

  bool loading = false;

  Future<void> runCompare() async {

    setState(() {
      loading = true;
      message = '';
    });

    final result =
        await CompareTwoFiles.run();

    setState(() {
      loading = false;

      if (result == null) {
        message = 'تم إلغاء العملية';
      } else {
        message = 'تم إنشاء ملف المقارنة:\n$result';
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('مقارنة ملفات Excel'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            const Text(
              'اضغط لبدء مقارنة ملفين Excel',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: loading ? null : runCompare,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('اختيار ومقارنة الملفات'),
            ),

            const SizedBox(height: 20),

            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
