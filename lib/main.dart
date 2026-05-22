import 'package:flutter/material.dart';

import 'screens/main_app.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Admin App',

      theme: ThemeData(

        useMaterial3: true,

        primarySwatch: Colors.indigo,

        scaffoldBackgroundColor:
            Colors.grey.shade100,

        appBarTheme: const AppBarTheme(

          centerTitle: true,

          elevation: 1,

          backgroundColor: Colors.indigo,

          foregroundColor: Colors.white,
        ),

        inputDecorationTheme:
            const InputDecorationTheme(

          border:
              OutlineInputBorder(),
        ),
      ),

      // =========================
      // اتجاه التطبيق عربي
      // =========================

      builder: (context, child) {

        return Directionality(

          textDirection:
              TextDirection.rtl,

          child: child!,
        );
      },

      // =========================
      // التطبيق الرئيسي
      // =========================

      home: const MainApp(),
    );
  }
}
