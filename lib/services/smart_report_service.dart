class SmartReportService {

  static String generateReport(Map<String, dynamic> diff) {

    final summary = diff["summary"] ?? {};

    final int newCount = summary["newCount"] ?? 0;
    final int missingCount = summary["missingCount"] ?? 0;
    final int changedCount = summary["changedCount"] ?? 0;
    final int stableCount = summary["stableCount"] ?? 0;

    String report = "📊 تقرير المباينة العسكري\n\n";

    // 📌 الحالة العامة
    if (missingCount > newCount + 2) {
      report += "⚠️ الحالة: غير مستقرة\n";
    } else if (changedCount > 0) {
      report += "🟡 الحالة: تغييرات ملحوظة\n";
    } else {
      report += "✅ الحالة: مستقرة\n";
    }

    report += "\n";

    // 📌 التفاصيل
    report += "👥 الجدد: $newCount\n";
    report += "❌ الغائبين: $missingCount\n";
    report += "🔁 المتغيرين: $changedCount\n";
    report += "📌 الثابتين: $stableCount\n\n";

    // 📌 توصيات تلقائية
    report += "📎 التوصيات:\n";

    if (missingCount > 0) {
      report += "- مراجعة أسباب الغياب\n";
    }

    if (changedCount > 0) {
      report += "- تدقيق حالات التحول الوظيفي\n";
    }

    if (newCount > 0) {
      report += "- توثيق الأفراد الجدد\n";
    }

    if (missingCount == 0 && changedCount == 0) {
      report += "- لا توجد ملاحظات، الوضع مستقر\n";
    }

    return report;
  }
}
