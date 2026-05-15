import 'package:flutter/material.dart';
import '../features/import/excel_import.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {

  bool loading = false;
  String message = "لم يتم الاستيراد بعد";

  Future<void> startImport() async {

    setState(() {
      loading = true;
      message = "جاري استيراد الملف...";
    });

    try {
      await ExcelImport.importTimeline();

      setState(() {
        message = "تم الاستيراد بنجاح ✔";
      });

    } catch (e) {

      setState(() {
        message = "حدث خطأ أثناء الاستيراد ❌";
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
        title: const Text("استيراد البيانات"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.file_upload,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: startImport,
                    child: const Text("استيراد ملف Excel"),
                  ),
          ],
        ),
      ),
    );
  }
}
