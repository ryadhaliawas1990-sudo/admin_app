class NameMatcher {

  static String normalize(String name) {

    return name
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('.', '')
        .replaceAll(' ', '');
  }

  static bool isSimilar(String a, String b) {

    final n1 = normalize(a);
    final n2 = normalize(b);

    // إذا متشابهين بنسبة بسيطة
    return n1.contains(n2) || n2.contains(n1);
  }
}
