class ComparisonDiffService {

  static Map<String, dynamic> compareTwoMonths({
    required List<Map<String, dynamic>> monthA,
    required List<Map<String, dynamic>> monthB,
  }) {

    final Map<String, Map<String, dynamic>> mapA = {};
    final Map<String, Map<String, dynamic>> mapB = {};

    // تحويل الشهر الأول إلى Map حسب الرقم العسكري
    for (var p in monthA) {
      mapA[p["number"]] = p;
    }

    // تحويل الشهر الثاني
    for (var p in monthB) {
      mapB[p["number"]] = p;
    }

    final List<Map<String, dynamic>> newEntries = [];
    final List<Map<String, dynamic>> missing = [];
    final List<Map<String, dynamic>> unchanged = [];
    final List<Map<String, dynamic>> changed = [];

    // 🔵 تحليل الشهر الثاني
    for (var number in mapB.keys) {

      if (!mapA.containsKey(number)) {
        newEntries.add(mapB[number]!);
      } else {

        final a = mapA[number]!;
        final b = mapB[number]!;

        if (a["status"] == b["status"]) {
          unchanged.add(b);
        } else {
          changed.add({
            "number": number,
            "name": b["name"],
            "rank": b["rank"],
            "from": a["status"],
            "to": b["status"],
          });
        }
      }
    }

    // 🔴 الذين اختفوا
    for (var number in mapA.keys) {
      if (!mapB.containsKey(number)) {
        missing.add(mapA[number]!);
      }
    }

    return {
      "new": newEntries,
      "missing": missing,
      "unchanged": unchanged,
      "changed": changed,
      "summary": {
        "newCount": newEntries.length,
        "missingCount": missing.length,
        "changedCount": changed.length,
        "stableCount": unchanged.length,
      }
    };
  }
}
