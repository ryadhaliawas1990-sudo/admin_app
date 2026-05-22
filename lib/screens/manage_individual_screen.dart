import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ManageIndividualScreen extends StatefulWidget {
  const ManageIndividualScreen({super.key});

  @override
  State<ManageIndividualScreen> createState() =>
      _ManageIndividualScreenState();
}

class _ManageIndividualScreenState extends State<ManageIndividualScreen> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _statusController = TextEditingController();

  String selectedRank = 'جندي';
  String selectedMonth = '1';
  String selectedYear = DateTime.now().year.toString();

  final List<String> ranks = [
    'جندي','عريف','رقيب','رقيب أول','ملازم','ملازم أول','نقيب',
    'رائد','مقدم','عقيد','عميد','لواء'
  ];

  final List<String> months =
      List.generate(12, (i) => (i + 1).toString());

  final List<String> years =
      List.generate(10, (i) => (2023 + i).toString());

  Future<void> _saveIndividual() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'number': _numberController.text.trim(),
      'name': _nameController.text.trim(),
      'rank': selectedRank,
      'unit': _unitController.text.trim(),
      'status': _statusController.text.trim(),
      'month': selectedMonth,
      'year': selectedYear,
    };

    try {
      final existing =
          await DBHelper.getPersonTimeline(data['number'] as String);

      final match = existing.where(
        (e) =>
            e['month'] == selectedMonth &&
            e['year'] == selectedYear,
      );

      if (match.isNotEmpty) {
        // 🔴 UPDATE يحتاج ID
        final id = match.first['id'] as int;

        await DBHelper.updateTimeline(id, data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث بيانات الفرد ✔")),
        );
      } else {
        await DBHelper.insertTimeline(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إضافة الفرد ✔")),
        );
      }

      _numberController.clear();
      _nameController.clear();
      _unitController.clear();
      _statusController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأفراد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'الرقم العسكري',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedRank,
                      items: ranks
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedRank = v!),
                      decoration: const InputDecoration(
                        labelText: 'الرتبة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'الوحدة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      items: months
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedMonth = v!),
                      decoration: const InputDecoration(
                        labelText: 'الشهر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      items: years
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text(y),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedYear = v!),
                      decoration: const InputDecoration(
                        labelText: 'السنة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveIndividual,
                child: const Text("حفظ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
