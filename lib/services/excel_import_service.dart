import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../db/db_helper.dart';

class ExcelImportService {

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

      // 🛡️ تصفير السجلات القديمة أولاً
      await DBHelper.deleteMonthData(selectedMonth, selectedYear);

      int processedCount = 0; // عداد للتحقق من السجلات

      for (var tableName in excel.tables.keys) {
        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        for (int i = 1; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          final number = row.length > 1 ? row[1]?.value?.toString().trim() ?? "" : "";
          final rank   = row.length > 2 ? row[2]?.value?.toString().trim() ?? "" : "";
          final name   = row.length > 3 ? row[3]?.value?.toString().trim() ?? "" : "";
          final unit   = row.length > 4 ? row[4]?.value?.toString().trim() ?? "" : "";
          final status = row.length > 5 ? row[5]?.value?.toString().trim() ?? "" : "";

          if (number.isEmpty && name.isEmpty) continue;

          // إدخال مباشر لضمان التسلسل والتحقق
          await DBHelper.insertTimeline({
            'number': number,
            'name': name,
            'rank': rank,
            'unit': unit,
            'status': status.isEmpty ? "-" : status,
            'month': selectedMonth,
            'year': selectedYear,
          });
          processedCount++;
        }
      }

      if (processedCount == 0) {
        return {"success": false, "message": "فشل: لم يتم العثور على أي بيانات داخل ملف الإكسل"};
      }

      await DBHelper.markMonthImported(selectedMonth, selectedYear);
      return {"success": true, "message": "تم استيراد $processedCount سجل بنجاح"};

    } catch (e) {
      return {"success": false, "message": "حدث خطأ أثناء المعالجة: $e"};
    }
  }

  static Future<bool> deleteFullMonth(String month, String year) async {
    try {
      final db = await DBHelper.database;
      await DBHelper.deleteMonthData(month, year);
      await db.delete(
        'imported_months',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
