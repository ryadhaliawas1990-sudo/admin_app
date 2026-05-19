import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ManageIndividualScreen extends StatefulWidget {
  const ManageIndividualScreen({super.key});

  @override
  State<ManageIndividualScreen> createState() => _ManageIndividualScreenState();
}

class _ManageIndividualScreenState extends State<ManageIndividualScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  String selectedRank = 'جندي';
  String selectedMonth = '1';
  String selectedYear = DateTime.now().year.toString();

  // 🪖 القائمة الرسمية المحدثة والشاملة للرتب العسكرية العادية والركن
  final List<String> ranks = [
    'جندي', 'عريف', 'رقيب', 'رقيب أول', 'ملازم', 'ملازم أول', 'نقيب', 
    'رائد', 'رائد ركن', 'مقدم', 'مقدم ركن', 'عقيد', 'عقيد ركن', 
    'عميد', 'عميد ركن', 'لواء', 'لواء ركن'
  ];
  
  final List<String> months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  final List<String> years = List.generate(10, (index) => (2023 + index).toString());

  Future<void> _saveIndividual() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {
      'number': _numberController.text.trim(),
      'name': _nameController.text.trim(),
      'rank': selectedRank,
      'unit': _unitController.text.trim(),
      'status': _statusController.text.trim().isEmpty ? "-" : _statusController.text.trim(),
      'month': selectedMonth,
      'year': selectedYear,
    };

    try {
      final existing = await DBHelper.getPersonTimeline(_numberController.text.trim());
      bool isDuplicateForMonth = existing.any((element) => element['month'] == selectedMonth && element['year'] == selectedYear);

      if (isDuplicateForMonth) {
        await DBHelper.updatePersonStatus(_numberController.text.trim(), selectedMonth, selectedYear, data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث بيانات وتعديل حالة الفرد بنجاح ✔")));
      } else {
        await DBHelper.insertTimeline(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إضافة سجل الفرد يدوياً بنجاح ✔")));
      }

      _numberController.clear();
      _nameController.clear();
      _unitController.clear();
      _statusController.clear();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ أثناء الحفظ: $e ❌")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة وتعديل الأفراد يدوياً')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("استمارة تسجيل قيد فرد استثنائي", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 20),

              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الرقم العسكري', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء إدخال الرقم العسكري' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء إدخال الاسم الكامل' : null,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedRank,
                      decoration: const InputDecoration(labelText: 'الرتبة', border: OutlineInputBorder()),
                      items: ranks.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() { if (v != null) selectedRank = v; }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'الوحدة / القسم', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء تحديد الوحدة' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'الحالة الحالية بالفرد', border: OutlineInputBorder(), prefixIcon: Icon(Icons.rule)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'برجاء تدوين حالة الفرد' : null,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: const InputDecoration(labelText: 'عن شهر', border: OutlineInputBorder()),
                      items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() { if (v != null) selectedMonth = v; }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      decoration: const InputDecoration(labelText: 'عن سنة', border: OutlineInputBorder()),
                      items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) => setState(() { if (v != null) selectedYear = v; }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveIndividual,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 10),
                    Text('حفظ القيود في السجل العام', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
