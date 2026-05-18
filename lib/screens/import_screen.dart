import 'package:flutter/material.dart';
// استدعاء ملف الخدمة المحصن الجديد (تأكد من صحة المسار حسب مجلداتك)
import '../services/excel_import_service.dart'; 

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool loading = false;
  String message = 'اختر الشهر والسنة ثم استورد الملف';
  String selectedMonth = '1';
  String selectedYear = DateTime.now().year.toString();

  final List<String> months = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
  ];

  final List<String> years = List.generate(
    10,
    (index) => (2023 + index).toString(),
  );

  /// 🚀 دالة بدء الاستيراد الآمنة والمعدلة لمنع تجميد المؤشر
  Future<void> startImport() async {
    setState(() {
      loading = true;
      message = 'جاري استيراد الملف...';
    });

    try {
      // 🔗 ربط مباشر مع الدالة المطورة وتمرير التاريخ المختار لمنع التكرار اللامحدود
      final Map<String, dynamic> result = await ExcelImportService.pickAndReadExcel(
        selectedMonth,
        selectedYear,
      );

      // 🔍 فحص حالة النتيجة الفعلية وبناء الواجهة بناءً عليها
      if (result["success"] == true) {
        setState(() {
          message = 'تم الاستيراد بنجاح ✔\n${result["message"]}';
        });
      } else {
        setState(() {
          message = 'تنبيه: ${result["message"]} ⚠️';
        });
      }

    } catch (e) {
      setState(() {
        message = 'حدث خطأ غير متوقع أثناء الاستيراد ❌';
      });
      print("🚨 خطأ في واجهة الاستيراد: $e");
    } finally {
      // 🛡️ حماية حتمية: إيقاف مؤشر التحميل فوراً تحت أي ظرف (سواء نجاح، خطأ، أو إلغاء)
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استيراد Excel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // نص حالة الاستيراد والرسائل الإدارية
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: loading ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // اختيار الشهر
            DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: const InputDecoration(
                labelText: 'الشهر',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 20),

            // اختيار السنة
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: const InputDecoration(
                labelText: 'السنة',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 30),

            // تحكّم ذكي بمؤشر التحميل والزر
            loading
                ? const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("برجاء الانتظار، يتم معالجة ومزامنة البيانات...", 
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                : ElevatedButton(
                    onPressed: startImport,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // زر عريض يسهل النقر عليه بالهاتف
                    ),
                    child: const Text(
                      'استيراد الملف',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
