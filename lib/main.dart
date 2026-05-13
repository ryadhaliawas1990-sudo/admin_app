import 'package:flutter/material.dart';

import 'screens/main_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ هذا هو التطبيق الحقيقي
      home: MainApp(),
    );
  }
}
