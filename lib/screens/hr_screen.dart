import 'package:flutter/material.dart';

import '../features/excel_compare/compare_two_files.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {

  String resultMessage = '';

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('HR Screen'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {

                      setState(() {
                        loading = true;
                        resultMessage = '';
                      });

                      final result =
                          await CompareTwoFiles.run();

                      setState(() {
                        loading = false;

                        if (result == null) {
                          resultMessage = 'تم إلغاء العملية';
                        } else {
                          resultMessage =
                              'تم حفظ الملف:\n$result';
                        }
                      });
                    },

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('مقارنة ملفين Excel'),
            ),

            const SizedBox(height: 20),

            Text(
              resultMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
