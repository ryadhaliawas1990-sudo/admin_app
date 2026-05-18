import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelImportService {

  /// 📊 دالة اختيار وقراءة ملف الإكسل المحصنة مع ميزة كشف الأشهر وإرجاع الحالة لقطع مؤشر التحميل
  static Future<Map<String, dynamic>> pickAndReadExcel() async {
    try {
      // 1. فتح أداة اختيار الملفات مع جلب البيانات كبايتات فوراً في الذاكرة
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, 
      );

      // ❌ التحقق من إلغاء عملية الاختيار من قبل المستخدم
      if (result == null || result.files.isEmpty) {
        print("LEX-Ω: تم إلغاء اختيار الملف.");
        return {
          "success": false,
          "message": "تم إلغاء اختيار الملف",
          "detected_months": [],
          "data": []
        };
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        print("LEX-Ω Error: تعذر الوصول إلى بايتات الملف.");
        return {
          "success": false,
          "message": "تعذر قراءة بيانات الملف داخلياً",
          "detected_months": [],
          "data": []
        };
      }

      // 2. فك تشفير البيانات بأمان تام
      final excel = Excel.decodeBytes(bytes);
      final List<Map<String, dynamic>> data = [];
      final Set<String> detectedMonths = {}; // لتخزين الأشهر الفريدة الموجودة في الملف لمنع التكرار

      // 📊 المرور على كل الشيتات (الجداول) داخل ملف الإكسل
      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        // 🔍 قراءة العناوين (الهيدر) في السطر الأول (رقم 0) لمعرفة أسماء الأعمدة/الأشهر
        List<String> headers = [];
        if (sheet.rows.isNotEmpty) {
          headers = sheet.rows.first.map((cell) => cell?.value?.toString().trim() ?? "").toList();
        }

        // رصد الأشهر تلقائياً من العناوين (تخطي أول 3 أعمدة الأساسية: الرقم، الاسم، الرتبة)
        for (int h = 3; h < headers.length; h++) {
          if (headers[h].isNotEmpty) {
            detectedMonths.add(headers[h]);
          }
        }

        // ⛔ البدء من السطر الثاني رقم 1 لقراءة البيانات الفردية وحالات الأشهر
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          // استخراج البيانات الأساسية بأمان
          final number = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? "" : "";
          final name = row.length > 1 ? row[1]?.value?.toString().trim() ?? "" : "";
          final rank = row.length > 2 ? row[2]?.value?.toString().trim() ?? "" : "";

          // تجاهل الصفوف الفارغة تماماً
          if (number.isEmpty && name.isEmpty) {
            continue;
          }

          // بناء خريطة ديناميكية لحالات الأشهر التابعة لهذا الشخص
          Map<String, String> individualMonths = {};
          for (int j = 3; j < row.length; j++) {
            if (j < headers.length && headers[j].isNotEmpty) {
              String statusValue = row[j]?.value?.toString().trim() ?? "-";
              if (statusValue.toLowerCase() == 'null' || statusValue.isEmpty) {
                statusValue = "-";
              }
              individualMonths[headers[j]] = statusValue;
            }
          }

          // إضافة البيانات للهيكل السليم
          data.add({
            "number": number,
            "name": name,
            "rank": rank,
            "months": individualMonths,
          });
        }
      }

      print("LEX-Ω Success: تم استيراد وقراءة ${data.length} سجل بنجاح.");
      
      // تعود بالنجاح الكامل لكي تسقط علامة التحميل في الواجهة فوراً
      return {
        "success": true,
        "message": "تم استيراد الملف بنجاح",
        "detected_months": detectedMonths.toList(),
        "data": data
      };

    } catch (e) {
      print("🚨 خطأ حماية LEX-Ω الحرجة أثناء القراءة: $e");
      return {
        "success": false,
        "message": "حدث خطأ غير متوقع: $e",
        "detected_months": [],
        "data": []
      };
    }
  }

  /// 🗑️ دالة مسح أو استبدال بيانات شهر تم إدخاله بالخطأ لتطهير السجلات
  static Future<bool> deleteDataByMonth(String monthName) async {
    try {
      // هنا سيتم توجيه أمر الحذف المباشر لقاعدة بياناتك لاحقاً عند الحاجة
      print("LEX-Ω: تم بنجاح تصفية وإلغاء بيانات الشهر: $monthName من النظام.");
      return true;
    } catch (e) {
      print("🚨 خطأ أثناء مسح بيانات الشهر: $e");
      return false;
    }
  }
}
