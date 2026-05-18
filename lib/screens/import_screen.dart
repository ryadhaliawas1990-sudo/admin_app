import 'package:flutter/material.dart';
import '../services/excel_import_service.dart'; 
import '../db/db_helper.dart'; 

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool loading = false;
  String message = 'اختر الشهر والسنة ثم استورد الملف';
  String selectedMonth = '1';
  String selectedYear = DateTime.now().year.toString();
  List<Map<String, dynamic>> importedMonthsList = []; 

  final List<String> months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  final List<String> years = List.generate(10, (index) => (2023 + index).toString());

  @override
  void initState() {
    super.initState();
    _loadImportedMonths(); 
  }

  Future<void> _loadImportedMonths() async {
    final data = await DBHelper.getImportedMonths();
    setState(() {
      importedMonthsList = data;
    });
  }

  Future<void> startImport() async {
    setState(() {
      loading = true;
      message = 'جاري استيراد الملف...';
    });

    try {
      final Map<String, dynamic> result = await ExcelImportService.pickAndReadExcel(
        selectedMonth,
        selectedYear,
      );

      if (result["success"] == true) {
        setState(() { message = 'تم الاستيراد بنجاح ✔'; });
        _loadImportedMonths(); 
      } else {
        setState(() { message = 'تنبيه: ${result["message"]} ⚠️'; });
      }

    } catch (e) {
      setState(() { message = 'حدث خطأ غير متوقع ❌'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  Future<void> _deleteMonth(String month, String year) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد من حذف كافة بيانات كشف شهر $month لعام $year؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("حذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await ExcelImportService.deleteFullMonth(month, year);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حذف الكشف وتطهير السجلات بنجاح")));
        _loadImportedMonths(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد وإدارة ملفات Excel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: const InputDecoration(labelText: 'الشهر', border: OutlineInputBorder()),
                    items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setState(() { if (v != null) selectedMonth = v; }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'السنة', border: OutlineInputBorder()),
                    items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                    onChanged: (v) => setState(() { if (v != null) selectedYear = v; }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            loading 
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("برجاء الانتظار، يتم معالجة ومزامنة البيانات...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              : ElevatedButton(
                  onPressed: startImport,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text('استيراد ملف جديد', style: TextStyle(fontSize: 16)),
                ),
            
            const SizedBox(height: 20),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            
            const Text("الكشوفات المستوردة حالياً بالنظام", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            
            Expanded(
              child: importedMonthsList.isEmpty
                  ? const Center(child: Text("لا توجد كشوفات مستوردة سابقة."))
                  : ListView.builder(
                      itemCount: importedMonthsList.length,
                      itemBuilder: (context, index) {
                        final item = importedMonthsList[index];
                        final m = item['month'] ?? '-';
                        final y = item['year'] ?? '-';
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.table_view, color: Colors.green),
                            title: Text("كشف شهر: $m / سنة: $y", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("تاريخ الاستيراد: ${item['imported_at']?.toString().split('T').first ?? '-'}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                              onPressed: () => _deleteMonth(m, y), 
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
