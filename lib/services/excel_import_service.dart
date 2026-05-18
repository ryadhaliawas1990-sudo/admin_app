import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../db/db_helper.dart';

class ExcelImportService {

  /// 📊 دالة اختيار وقراءة ملف الإكسل ومزامنته مع قاعدة البيانات بدقة
  static Future<Map<String, dynamic>> pickAndReadExcel(String selectedMonth, String selectedYear) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, 
      );

      if (result == null || result.files.isEmpty) {
        return {"success": false, "message": "تم إلغاء اختيار الملف"};
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        return {"success": false, "message": "تعذر قراءة بيانات الملف داخلياً"};
      }

      final excel = Excel.decodeBytes(bytes);

      // 🛡️ تنظيف السجلات القديمة للشهر المحدد لمنع التكرار تماماً عند إعادة الرفع
      await DBHelper.deleteMonthData(selectedMonth, selectedYear);

      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        // نبدأ من السطر الثاني (تخطي العناوين)
        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          // 📐 الترتيب العسكري الدقيق والمطابق لكشفك:
          // العمود 0 (A) = المتسلسل الرقمي (يتم تخطيه بناءً على طلبك)
          // العمود 1 (B) = الرقم العسكري
          // العمود 2 (C) = الرتبة
          // العمود 3 (D) = الاسم
          // العمود 4 (E) = الوحدة
          // العمود 5 (F) = الحاله
          
          final number = row.length > 1 ? row[1]?.value?.toString().trim() ?? "" : "";
          final rank   = row.length > 2 ? row[2]?.value?.toString().trim() ?? "" : "";
          final name   = row.length > 3 ? row[3]?.value?.toString().trim() ?? "" : "";
          final unit   = row.length > 4 ? row[4]?.value?.toString().trim() ?? "" : "";
          final status = row.length > 5 ? row[5]?.value?.toString().trim() ?? "" : "";

          // إذا كان الرقم والاسم فارغين نتخطى السطر
          if (number.isEmpty && name.isEmpty) continue;

          // حقن البيانات في الـ Database الحقيقية بتوافق 100% بدون أي تداخل
          await DBHelper.insertTimeline({
            'number': number,
            'name': name,
            'rank': rank,
            'unit': unit, 
            'status': status.isEmpty ? "-" : status,
            'month': selectedMonth,
            'year': selectedYear,
          });
        }
      }

      // 📝 تسجيل الشهر في جدول الأشهر المستوردة للمراقبة والحذف لاحقاً
      await DBHelper.markMonthImported(selectedMonth, selectedYear);

      return {"success": true, "message": "تم الاستيراد والمزامنة بنجاح وبترتيب الأعمدة الصحيح"};

    } catch (e) {
      print("🚨 خطأ في الاستيراد: $e");
      return {"success": false, "message": "حدث خطأ أثناء المعالجة: $e"};
    }
  }

  /// 🗑️ دالة مسح كامل كشف الشهر والسنة المستوردين وتطهير السجلات
  static Future<bool> deleteFullMonth(String month, String year) async {
    try {
      final db = await DBHelper.database;
      
      // 1. حذف البيانات من جدول الـ timeline
      await DBHelper.deleteMonthData(month, year);
      
      // 2. حذف الشهر من سجل الجدول المساعد imported_months
      await db.delete(
        'imported_months',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
      );
      
      return true;
    } catch (e) {
      print("🚨 خطأ أثناء حذف الكشف: $e");
      return false;
    }
  }
}
