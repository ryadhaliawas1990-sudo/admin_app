import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../db/db_helper.dart';

class ExcelImportService {

  // =========================
  // اختيار وقراءة ملف Excel
  // =========================

  static Future<Map<String, dynamic>> pickAndReadExcel(
    String selectedMonth,
    String selectedYear,
  ) async {

    try {

      // =========================
      // اختيار الملف
      // =========================

      final result =
          await FilePicker.platform.pickFiles(

        type: FileType.custom,

        allowedExtensions: [
          'xlsx',
          'xls',
        ],

        withData: true,
      );

      if (result == null ||
          result.files.isEmpty) {

        return {

          "success": false,

          "message":
              "تم إلغاء اختيار الملف"
        };
      }

      final file =
          result.files.first;

      final bytes =
          file.bytes;

      if (bytes == null) {

        return {

          "success": false,

          "message":
              "تعذر قراءة الملف"
        };
      }

      // =========================
      // قراءة الإكسل
      // =========================

      final excel =
          Excel.decodeBytes(bytes);

      // =========================
      // حذف بيانات الشهر القديم
      // =========================

      await DBHelper.deleteMonth(
        selectedMonth,
        selectedYear,
      );

      int processedCount = 0;

      // =========================
      // قراءة جميع الشيتات
      // =========================

      for (final tableName
          in excel.tables.keys) {

        final sheet =
            excel.tables[tableName];

        if (sheet == null) {
          continue;
        }

        // =========================
        // بدء القراءة من الصف الثاني
        // =========================

        for (
          int i = 1;
          i < sheet.rows.length;
          i++
        ) {

          final row =
              sheet.rows[i];

          if (row.isEmpty) {
            continue;
          }

          // =========================
          // قراءة الخلايا بأمان
          // =========================

          String readCell(
            int index,
          ) {

            if (index >= row.length) {
              return "";
            }

            final cell =
                row[index];

            if (cell == null ||
                cell.value == null) {

              return "";
            }

            return cell.value
                .toString()
                .trim();
          }

          // =========================
          // ترتيب الأعمدة
          // A = تسلسل
          // B = الرقم العسكري
          // C = الرتبة
          // D = الاسم
          // E = الوحدة
          // F = الحالة
          // =========================

          final number =
              readCell(1);

          final rank =
              readCell(2);

          final name =
              readCell(3);

          final unit =
              readCell(4);

          final status =
              readCell(5);

          // =========================
          // تجاهل الصفوف الفارغة
          // =========================

          if (number.isEmpty &&
              name.isEmpty) {

            continue;
          }

          // =========================
          // تنظيف الحالة
          // =========================

          String finalStatus =
              status.trim();

          if (finalStatus.isEmpty ||
              finalStatus == "null") {

            finalStatus = "-";
          }

          // =========================
          // حفظ البيانات
          // =========================

          await DBHelper.insertTimeline({

            'number': number,

            'name': name,

            'rank': rank,

            'unit': unit,

            'status': finalStatus,

            'month': selectedMonth,

            'year': selectedYear,
          });

          processedCount++;
        }
      }

      // =========================
      // لا توجد بيانات
      // =========================

      if (processedCount == 0) {

        return {

          "success": false,

          "message":
              "لم يتم العثور على بيانات داخل الملف"
        };
      }

      // =========================
      // نجاح
      // =========================

      return {

        "success": true,

        "message":
            "تم استيراد $processedCount سجل بنجاح"
      };

    } catch (e) {

      return {

        "success": false,

        "message":
            "حدث خطأ أثناء الاستيراد: $e"
      };
    }
  }

  // =========================
  // حذف شهر كامل
  // =========================

  static Future<bool> deleteFullMonth(
    String month,
    String year,
  ) async {

    try {

      await DBHelper.deleteMonth(
        month,
        year,
      );

      return true;

    } catch (e) {

      return false;
    }
  }
}
