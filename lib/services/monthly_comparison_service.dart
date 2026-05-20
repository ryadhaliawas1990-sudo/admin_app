import '../db/db_helper.dart';

class MonthlyComparisonService {
  static Future<Map<String, dynamic>> build({
    required List<String> months,
  }) async {

    final dataByMonth = <String, List<Map<String, dynamic>>>{};

    // تحميل بيانات كل شهر
    for (var m in months) {
      dataByMonth[m] =
          await DBHelper.getPersonTimeline(int.parse(m));
    }

    // تجميع كل الأشخاص
    final allPeople = <String, Map<String, dynamic>>{};

    for (var m in months) {
      for (var p in dataByMonth[m]!) {
        allPeople[p["number"].toString()] = p;
      }
    }

    // بناء النتيجة النهائية
    final result = <Map<String, dynamic>>[];

    for (var person in allPeople.values) {

      final monthsMap = <String, String>{};

      for (var m in months) {

        final list = dataByMonth[m] ?? [];

        final found = list.where(
          (e) => e["number"].toString() ==
              person["number"].toString(),
        );

        monthsMap[m] =
            found.isNotEmpty
                ? found.first["status"].toString()
                : "-";
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
