class MonthlyComparisonService {

  static Future<Map<String, dynamic>> build({
    required List<String> months,
  }) async {

    final dataByMonth = <String, List<Map<String, dynamic>>>{};

    for (var m in months) {
      dataByMonth[m] = await DBHelper.getByMonth(m);
    }

    final allPeople = <String, Map<String, dynamic>>{};

    for (var m in months) {
      for (var p in dataByMonth[m]!) {
        allPeople[p["number"]] = p;
      }
    }

    final result = <Map<String, dynamic>>[];

    for (var person in allPeople.values) {

      final monthsMap = <String, String>{};

      for (var m in months) {

        final list = dataByMonth[m] ?? [];

        final found = list.where(
          (e) => e["number"] == person["number"],
        );

        if (found.isNotEmpty) {
          monthsMap[m] = found.first["status"];
        } else {
          monthsMap[m] = "-";
        }
      }

      result.add({
        "number": person["number"],
        "name": person["name"],
        "rank": person["rank"],
        "months": monthsMap,
      });
    }

    return {
      "people": result,
      "months": months,
    };
  }
}
