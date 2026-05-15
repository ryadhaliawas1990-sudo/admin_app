import 'package:flutter/material.dart';

class ReportsArchiveScreen
    extends StatelessWidget {

  const ReportsArchiveScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'الأرشيف',
        ),
      ),

      body: const Center(

        child: Text(
          'الأرشيف جاهز',
        ),
      ),
    );
  }
}
