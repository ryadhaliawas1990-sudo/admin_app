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

  final List<String> months = List.generate(12, (i) => (i + 1).toString());
  final List<String> years = List.generate(10, (i) => (2023 + i).toString());

  @override
  void initState() {
    super.initState();
    _loadImportedMonths();
  }

  Future<void> _loadImportedMonths() async {
    final data = await DBHelper.getImportedMonths();

    if (!mounted) return;

    setState(() {
      importedMonthsList =
          List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> startImport() async {
    setState(() {
      loading = true;
      message = 'جاري استيراد الملف...';
    });

    try {
      final result = await ExcelImportService.pickAndReadExcel(
        selectedMonth,
        selectedYear,
      );

      if (result['success'] == true) {
        setState(() {
          message = 'تم الاستيراد بنجاح ✔';
        });

        await _loadImportedMonths();
      } else {
        setState(() {
          message = 'تنبيه: ${result['message']} ⚠️';
        });
      }
    } catch (_) {
      setState(() {
        message = 'حدث خطأ غير متوقع ❌';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _deleteMonth(String month, String year) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: Text("هل تريد حذف كشف شهر $month لعام $year؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "حذف",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success =
        await ExcelImportService.deleteFullMonth(month, year);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم الحذف بنجاح")),
      );

      await _loadImportedMonths();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد الملفات')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'الشهر',
                      border: OutlineInputBorder(),
                    ),
                    items: months
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedMonth = v);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'السنة',
                      border: OutlineInputBorder(),
                    ),
                    items: years
                        .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text(y),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => selectedYear = v);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: startImport,
                    child: const Text("استيراد"),
                  ),

            const SizedBox(height: 20),
            const Divider(),

            const Text(
              "الكشوفات المستوردة",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: importedMonthsList.isEmpty
                  ? const Center(child: Text("لا يوجد بيانات"))
                  : ListView.builder(
                      itemCount: importedMonthsList.length,
                      itemBuilder: (context, index) {
                        final item = importedMonthsList[index];

                        final m = item['month']?.toString() ?? '-';
                        final y = item['year']?.toString() ?? '-';

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.table_chart),
                            title: Text("شهر $m / سنة $y"),
                            subtitle: Text(
                              item['imported_at']?.toString() ?? '',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () =>
                                  _deleteMonth(m, y),
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













