import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../db/db_helper.dart'; // الربط المباشر مع ملفك الخاص

class ExcelImportService {

  /// 📊 دالة اختيار وقراءة ملف الإكسل ومزامنته مع قاعدة البيانات وحظر التكرار
  static Future<Map<String, dynamic>> pickAndReadExcel(String selectedMonth, String selectedYear) async {
    try {
      // 1. فتح أداة اختيار الملفات بأمان بالبايتات
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, 
      );

      // ❌ إذا ألغى المستخدم الاختيار، نغلق الدالة فوراً لإيقاف المؤشر
      if (result == null || result.files.isEmpty) {
        print("LEX-Ω: تم إلغاء اختيار الملف.");
        return {"success": false, "message": "تم إلغاء اختيار الملف"};
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        return {"success": false, "message": "تعذر قراءة بيانات الملف داخلياً"};
      }

      final excel = Excel.decodeBytes(bytes);
      final db = await DBHelper.database; 

      // 🛡️ حظر تكرار الكشف كامل: إذا كان هذا الشهر والسنة مستوردين سابقاً، نمسح البيانات القديمة أولاً للاستبدال!
      await DBHelper.deleteMonthData(selectedMonth, selectedYear);

      // المرور على الجداول داخل ملف الإكسل
      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        // البدء من السطر الثاني (تخطي الهيدر)
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          // قراءة البيانات من الأعمدة الثلاثة الأولى (الرقم، الاسم، الرتبة/الحالة)
          final number = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? "" : "";
          final name = row.length > 1 ? row[1]?.value?.toString().trim() ?? "" : "";
          final status = row.length > 2 ? row[2]?.value?.toString().trim() ?? "" : "";

          // تجاهل الصفوف الفارغة
          if (number.isEmpty && name.isEmpty) continue;

          // حقن البيانات في جدول timeline الخاص بك بشكل متوافق 100%
          await DBHelper.insertTimeline({
            'number': number,
            'name': name,
            'rank': '', // اتركها فارغة أو املأها إذا كانت متوفرة بكشفك
            'unit': '', 
            'status': status.isEmpty ? "-" : status,
            'month': selectedMonth,
            'year': selectedYear,
          });
        }
      }

      // 📝 تسجيل الشهر في جدول الأشهر المستوردة حتى لا ينساه النظام
      await DBHelper.markMonthImported(selectedMonth, selectedYear);

      print("LEX-Ω Success: تمت المزامنة بنجاح تام.");
      return {"success": true, "message": "تم الاستيراد والمزامنة بنجاح"};

    } catch (e) {
      print("🚨 خطأ حماية LEX-Ω في الاستيراد: $e");
      return {"success": false, "message": "حدث خطأ أثناء المعالجة: $e"};
    }
  }
}
