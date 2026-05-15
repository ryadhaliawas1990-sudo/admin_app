import 'package:flutter/material.dart';

import '../features/import/excel_import.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() =>
      _ImportScreenState();
}

class _ImportScreenState
    extends State<ImportScreen> {

  bool loading = false;

  String message =
      'اختر الشهر والسنة ثم استورد الملف';

  String selectedMonth = '1';

  String selectedYear =
      DateTime.now().year.toString();

  final List<String> months = [

    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  final List<String> years = List.generate(
    10,
    (index) =>
        (2023 + index).toString(),
  );

  Future<void> startImport() async {

    setState(() {

      loading = true;

      message =
          'جاري استيراد الملف...';
    });

    try {

      await ExcelImport.importTimeline(

        month: selectedMonth,
        year: selectedYear,
      );

      setState(() {

        message =
            'تم الاستيراد بنجاح ✔';
      });

    } catch (e) {

      setState(() {

        message =
            'حدث خطأ أثناء الاستيراد ❌';
      });

    } finally {

      setState(() {

        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text('استيراد Excel'),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Text(
              message,

              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 30,
            ),

            // اختيار الشهر
            DropdownButtonFormField<String>(

              value: selectedMonth,

              decoration:
                  const InputDecoration(

                labelText: 'الشهر',
                border:
                    OutlineInputBorder(),
              ),

              items: months.map((m) {

                return DropdownMenuItem(

                  value: m,

                  child: Text(m),
                );
              }).toList(),

              onChanged: (v) {

                if (v != null) {

                  setState(() {

                    selectedMonth = v;
                  });
                }
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // اختيار السنة
            DropdownButtonFormField<String>(

              value: selectedYear,

              decoration:
                  const InputDecoration(

                labelText: 'السنة',
                border:
                    OutlineInputBorder(),
              ),

              items: years.map((y) {

                return DropdownMenuItem(

                  value: y,

                  child: Text(y),
                );
              }).toList(),

              onChanged: (v) {

                if (v != null) {

                  setState(() {

                    selectedYear = v;
                  });
                }
              },
            ),

            const SizedBox(
              height: 30,
            ),

            loading

                ? const CircularProgressIndicator()

                : ElevatedButton(

                    onPressed:
                        startImport,

                    child: const Text(
                      'استيراد الملف',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
