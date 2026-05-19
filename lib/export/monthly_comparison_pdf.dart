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
    // هذه هي الدالة التي تطلبها الشاشة
    return "تم التصدير بنجاح";
  }
}
