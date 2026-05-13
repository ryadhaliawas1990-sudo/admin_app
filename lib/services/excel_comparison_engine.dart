class ExcelComparisonEngine {

  static Map<String, dynamic> compare({
    required List<Map<String, dynamic>> listA,
    required List<Map<String, dynamic>> listB,
  }) {

    final mapA = {
      for (var e in listA) e["number"]: e
    };

    final mapB = {
      for (var e in listB) e["number"]: e
    };

    final allKeys = {...mapA.keys, ...mapB.keys};

    List<Map<String, dynamic>> inBoth = [];
    List<Map<String, dynamic>> onlyA = [];
    List<Map<String, dynamic>> onlyB = [];

    for (var key in allKeys) {

      final a = mapA[key];
      final b = mapB[key];

      if (a != null && b != null) {
        inBoth.add(a);
      }

      if (a != null && b == null) {
        onlyA.add(a);
      }

      if (a == null && b != null) {
        onlyB.add(b);
      }
    }

    return {
      "inBoth": inBoth,
      "onlyA": onlyA,
      "onlyB": onlyB,
      "summary": {
        "inBothCount": inBoth.length,
        "onlyACount": onlyA.length,
        "onlyBCount": onlyB.length,
      }
    };
  }
}
