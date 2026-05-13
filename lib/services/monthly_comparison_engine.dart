class MonthlyComparisonEngine {

  static Map<String, dynamic> compare({
    required List<Map<String, dynamic>> people,
    required List<String> months,
    required Map<String, List<Map<String, dynamic>>> dataByMonth,
  }) {

    List<Map<String, dynamic>> result = [];

    for (var person in people) {

      Map<String, String> statusByMonth = {};

      for (var month in months) {

        final monthData = dataByMonth[month] ?? [];

        final found = monthData.firstWhere(
          (e) => e["number"] == person["number"],
          orElse: () => {},
        );

        statusByMonth[month] = found["status"] ?? "-";
      }

      result.add({
        "number": person["number"],
        "name": person["name"],
        "months": statusByMonth,
      });
    }

    return {
      "result": result,
      "months": months,
    };
  }
}
