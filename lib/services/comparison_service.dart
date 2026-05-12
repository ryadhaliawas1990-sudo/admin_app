import '../db/db_helper.dart';

class ComparisonService {

  /// 📊 جلب المباينة بين عدة أشهر
  static Future<List<Map<String, dynamic>>> buildComparison(
    List<String> months,
  ) async {

    // 1️⃣ جلب البيانات لكل شهر
    Map<String, List<Map<String, dynamic>>> dataByMonth = {};

    for (String month in months) {
      final data = await DBHelper.getByMonth(month);
      dataByMonth[month] = data;
    }

    // 2️⃣ استخراج جميع الأشخاص بدون تكرار (حسب الرقم)
    Map<String, Map<String, dynamic>> peopleMap = {};

    for (String month in months) {
      for (var person in dataByMonth[month]!) {

        final number = (person['number'] ?? '').toString();

        if (number.isEmpty) continue;

        peopleMap[number] = {
          "number": number,
          "name": person['name'] ?? '',
          "rank": person['rank'] ?? '',
          "unit": person['unit'] ?? '',
          "months": <String, bool>{},
        };
      }
    }

    // 3️⃣ تعبئة حالة كل شهر (موجود / غير موجود)
    for (String month in months) {
      final monthData = dataByMonth[month]!;

      for (var person in peopleMap.values) {
        final exists = monthData.any(
          (e) => (e['number'] ?? '') == person['number'],
        );

        (person["months"] as Map<String, bool>)[month] = exists;
      }
    }

    // 4️⃣ تحويل Map إلى List
    return peopleMap.values.toList();
  }
}
