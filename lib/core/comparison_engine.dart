import '../db/db_helper.dart';

class ComparisonEngine {

  static Future<Map<String, dynamic>> compareMonths(
    String oldMonth,
    String newMonth,
  ) async {

    final oldRecords =
        await DBHelper.getMonthlyRecords(oldMonth);

    final newRecords =
        await DBHelper.getMonthlyRecords(newMonth);

    final Map<String, Map<String, dynamic>>
        oldMap = {

      for (var item in oldRecords)
        item['number'].toString(): item,
    };

    final Map<String, Map<String, dynamic>>
        newMap = {

      for (var item in newRecords)
        item['number'].toString(): item,
    };

    List<Map<String, dynamic>> changed = [];

    List<Map<String, dynamic>> disappeared = [];

    List<Map<String, dynamic>> added = [];

    // التغييرات والمختفين
    for (var number in oldMap.keys) {

      if (newMap.containsKey(number)) {

        final oldStatus =
            oldMap[number]!['status'];

        final newStatus =
            newMap[number]!['status'];

        if (oldStatus != newStatus) {

          changed.add({

            "number": number,

            "old_status": oldStatus,

            "new_status": newStatus,
          });
        }

      } else {

        disappeared.add({

          "number": number,
        });
      }
    }

    // الجدد
    for (var number in newMap.keys) {

      if (!oldMap.containsKey(number)) {

        added.add({

          "number": number,
        });
      }
    }

    return {

      "changed": changed,

      "disappeared": disappeared,

      "added": added,
    };
  }
}
