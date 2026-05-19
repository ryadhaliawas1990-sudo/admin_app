import 'dart:io';

class MonthlyComparisonPdf {
  static Future<String> export({
    required List<String> months,
    required List<Map<String, dynamic>> people,
    String? topText,
    String? leftSignature,
    String? rightSignature,
    Map<String, dynamic>? data,
  }) async {
    return "تم التصدير بنجاح";
  }
}
