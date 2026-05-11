import 'package:flutter/material.dart';

class AppRefresher {
  static final ValueNotifier<int> refreshNotifier =
      ValueNotifier<int>(0);

  // 🔄 استدعاء هذا بعد أي تغيير في البيانات
  static void refresh() {
    refreshNotifier.value++;
  }
}
