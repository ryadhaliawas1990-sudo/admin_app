import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelImportService {

  /// 📊 دالة اختيار وقراءة ملف الإكسل المحصنة ضد الانهيار في الهواتف
  static Future<List<Map<String, dynamic>>> pickAndReadExcel() async {
    try {
      // 1. فتح أداة اختيار الملفات مع جلب البيانات كبايتات فوراً في الذاكرة لضمان تخطي حماية الأندرويد
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // تضمن جلب البايتات مباشرة دون الحاجة للمسار الفيزيائي
      );

      // ❌ التحقق من إلغاء عملية الاختيار أو أن الملف فارغ
      if (result == null || result.files.isEmpty) {
        print("LEX-Ω: تم إلغاء اختيار الملف أو القائمة فارغة.");
        return [];
      }

      final file = result.files.first;

      // 🛠️ الحماية الحقيقية: نقرأ البايتات المباشرة من الذاكرة إذا كان المسار الفيزيائي null أو وهمي
      final bytes = file.bytes;
      if (bytes == null) {
        print("LEX-Ω Error: تعذر الوصول إلى بايتات الملف مباشرة.");
        return [];
      }

      // 2. فك تشفير البيانات بأمان تام
      final excel = Excel.decodeBytes(bytes);
      final List<Map<String, dynamic>> data = [];

      // 📊 المرور على كل الشيتات (الجداول) داخل ملف الإكسل
      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        // ⛔ تجاهل الهيدر (السطر الأول رقم 0) والبدء من السطر الثاني رقم 1
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];

          // تجاهل الصفوف الفارغة تماماً لتجنب استهلاك موارد المعالج
          if (row.isEmpty) continue;

          // 🛡️ استخراج البيانات بأمان تام ومنع الأخطاء حتى لو كانت الخلية فارغة أو تحتوي على نصوص عربية
          final number = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? "" : "";
          final name = row.length > 1 ? row[1]?.value?.toString().trim() ?? "" : "";
          final status = row.length > 2 ? row[2]?.value?.toString().trim() ?? "" : "";

          // ❌ تجاهل الصفوف إذا كان الرقم والاسم فارغين معاً
          if (number.isEmpty && name.isEmpty) {
            continue;
          }

          // إضافة البيانات الهيكلية للقائمة بنجاح
          data.add({
            "number": number,
            "name": name,
            "status": status,
          });
        }
      }

      print("LEX-Ω Success: تم استيراد وقراءة ${data.length} سجل بنجاح دون أي انهيار.");
      return data;

    } catch (e) {
      // اصطياد خطأ الـ Crash وعزل المشكلة تماماً لحماية استقرار التطبيق
      print("🚨 خطأ حماية LEX-Ω الحرجة أثناء القراءة: $e");
      return [];
    }
  }
}
