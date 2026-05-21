import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../db/db_helper.dart';

class ExcelImportService {

  static Future<Map<String, dynamic>> pickAndReadExcel(
      String selectedMonth,
      String selectedYear,
      ) async {

    try {

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return {
          "success": false,
          "message": "تم إلغاء اختيار الملف"
        };
      }

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        return {
          "success": false,
          "message": "تعذر قراءة بيانات الملف"
        };
      }

      final excel = Excel.decodeBytes(bytes);

      // حذف بيانات الشهر القديمة (نستخدم الدالة الموجودة فعليًا في DBHelper)
      await DBHelper.deleteMonth(selectedMonth, selectedYear);

      int processedCount = 0;

      for (var tableName in excel.tables.keys) {

        final sheet = excel.tables[tableName];
        if (sheet == null) continue;

        for (int i = 1; i < sheet.rows.length; i++) {

          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          String readCell(int index) {
            if (index >= row.length) return "";
            final cell = row[index];
            if (cell == null || cell.value == null) return "";
            return cell.value.toString().trim();
          }

          final number = readCell(1);
          final rank   = readCell(2);
          final name   = readCell(3);
          final unit   = readCell(4);
          final status = readCell(5);

          if (number.isEmpty && name.isEmpty) continue;

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
        return {
          "success": false,
          "message": "لم يتم العثور على بيانات في الملف"
        };
      }

      return {
        "success": true,
        "message": "تم استيراد $processedCount سجل بنجاح"
      };

    } catch (e) {
      return {
        "success": false,
        "message": "خطأ: $e"
      };
    }
  }

  static Future<bool> deleteFullMonth(String month, String year) async {
    try {
      await DBHelper.deleteMonth(month, year);
      return true;
    } catch (e) {
      return false;
    }
  }
}
