import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:excel/excel.dart';

import '../db/db_helper.dart';
import '../services/excel_to_db_service.dart';

class HrScreen extends StatefulWidget {
  const HrScreen({super.key});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {

  String selectedYear = "2026";

  String fromMonth = "يناير";
  String toMonth = "ديسمبر";

  final TextEditingController searchController =
      TextEditingController();

  String importYear = "2026";
  String importMonth = "1";

  bool isImporting = false;

  final List<String> years = [
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030"
  ];

  final List<String> months = [
    "يناير",
    "فبراير",
    "مارس",
    "أبريل",
    "مايو",
    "يونيو",
    "يوليو",
    "أغسطس",
    "سبتمبر",
    "أكتوبر",
    "نوفمبر",
    "ديسمبر"
  ];

  final Map<String, int> monthNumbers = {
    "يناير": 1,
    "فبراير": 2,
    "مارس": 3,
    "أبريل": 4,
    "مايو": 5,
    "يونيو": 6,
    "يوليو": 7,
    "أغسطس": 8,
    "سبتمبر": 9,
    "أكتوبر": 10,
    "نوفمبر": 11,
    "ديسمبر": 12,
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "إدارة الموارد البشرية",
        ),
        centerTitle: true,
      ),

      body: Directionality(
        textDirection: TextDirection.rtl,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: ListView(
            children: [

              // =========================
              // استيراد الإكسل
              // =========================

              _buildSectionTitle(
                "📥 استيراد كشوفات الأفراد",
              ),

              Card(
                color: Colors.blue.shade50,

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child:
                                DropdownButtonFormField<String>(

                              initialValue: importYear,

                              decoration:
                                  const InputDecoration(
                                labelText: "السنة",
                                border:
                                    OutlineInputBorder(),
                              ),

                              items: years
                                  .map(
                                    (y) =>
                                        DropdownMenuItem(
                                      value: y,
                                      child: Text(y),
                                    ),
                                  )
                                  .toList(),

                              onChanged: (v) {

                                if (v != null) {

                                  setState(() {
                                    importYear = v;
                                  });
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child:
                                DropdownButtonFormField<String>(

                              initialValue: importMonth,

                              decoration:
                                  const InputDecoration(
                                labelText: "الشهر",
                                border:
                                    OutlineInputBorder(),
                              ),

                              items: List.generate(
                                12,
                                (i) => (i + 1).toString(),
                              )
                                  .map(
                                    (m) =>
                                        DropdownMenuItem(
                                      value: m,
                                      child:
                                          Text("شهر $m"),
                                    ),
                                  )
                                  .toList(),

                              onChanged: (v) {

                                if (v != null) {

                                  setState(() {
                                    importMonth = v;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      isImporting
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green.shade700,
                              ),

                              onPressed:
                                  _pickAndImportExcel,

                              icon: const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),

                              label: const Text(
                                "رفع ملف Excel",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // إنشاء التقرير
              // =========================

              _buildSectionTitle(
                "📊 إنشاء تقرير PDF",
              ),

              DropdownButtonFormField<String>(

                initialValue: selectedYear,

                decoration: const InputDecoration(
                  labelText: "السنة",
                  border: OutlineInputBorder(),
                ),

                items: years
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(y),
                      ),
                    )
                    .toList(),

                onChanged: (v) {

                  if (v != null) {

                    setState(() {
                      selectedYear = v;
                    });
                  }
                },
              ),

              const SizedBox(height: 15),

              TextField(
                controller: searchController,

                decoration: const InputDecoration(
                  labelText:
                      "بحث بالرقم أو الاسم",
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.search),
                ),
              ),

              const SizedBox(height: 15),

              Row(

                children: [

                  Expanded(
                    child:
                        DropdownButtonFormField<String>(

                      initialValue: fromMonth,

                      decoration:
                          const InputDecoration(
                        labelText: "من شهر",
                        border:
                            OutlineInputBorder(),
                      ),

                      items: months
                          .map(
                            (m) =>
                                DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ),
                          )
                          .toList(),

                      onChanged: (v) {

                        if (v != null) {

                          setState(() {
                            fromMonth = v;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        DropdownButtonFormField<String>(

                      initialValue: toMonth,

                      decoration:
                          const InputDecoration(
                        labelText: "إلى شهر",
                        border:
                            OutlineInputBorder(),
                      ),

                      items: months
                          .map(
                            (m) =>
                                DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ),
                          )
                          .toList(),

                      onChanged: (v) {

                        if (v != null) {

                          setState(() {
                            toMonth = v;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue.shade700,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                onPressed:
                    _generateFilteredReport,

                child: const Text(
                  "إنشاء التقرير PDF",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Text(
        title,

        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  // =========================
  // استيراد الإكسل
  // =========================

  Future<void> _pickAndImportExcel() async {

    try {

      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null ||
          result.files.single.path == null) {
        return;
      }

      setState(() {
        isImporting = true;
      });

      final file =
          File(result.files.single.path!);

      final bytes =
          await file.readAsBytes();

      final excel =
          Excel.decodeBytes(bytes);

      final sheetName =
          excel.tables.keys.first;

      final sheet =
          excel.tables[sheetName];

      if (sheet == null) {
        throw Exception(
          "لا توجد بيانات داخل الملف",
        );
      }

      List<Map<String, dynamic>> rows = [];

      for (int i = 1; i < sheet.rows.length; i++) {

        final row = sheet.rows[i];

        rows.add({

          "number":
              row.length > 1
                  ? row[1]?.value
                          ?.toString() ??
                      ""
                  : "",

          "rank":
              row.length > 2
                  ? row[2]?.value
                          ?.toString() ??
                      ""
                  : "",

          "name":
              row.length > 3
                  ? row[3]?.value
                          ?.toString() ??
                      ""
                  : "",

          "unit":
              row.length > 4
                  ? row[4]?.value
                          ?.toString() ??
                      ""
                  : "",

          "status":
              row.length > 5
                  ? row[5]?.value
                          ?.toString() ??
                      ""
                  : "",

          "month": importMonth,
          "year": importYear,
        });
      }

      if (rows.isEmpty) {

        throw Exception(
          "الملف فارغ",
        );
      }

      await ExcelToDbService.import(
        rows,
        importMonth,
        importYear,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "تم الاستيراد بنجاح",
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "خطأ: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isImporting = false;
        });
      }
    }
  }

  // =========================
  // إنشاء التقرير
  // =========================

  Future<void> _generateFilteredReport() async {

    final startMonth =
        monthNumbers[fromMonth] ?? 1;

    final endMonth =
        monthNumbers[toMonth] ?? 12;

    final query =
        searchController.text.trim();

    final db = await DBHelper.database;

    List<Map<String, dynamic>> records;

    if (query.isEmpty) {

      records = await db.query(
        'timeline',
        where: 'year = ?',
        whereArgs: [selectedYear],
      );

    } else {

      records = await db.query(
        'timeline',
        where:
            'year = ? AND (number LIKE ? OR name LIKE ?)',
        whereArgs: [
          selectedYear,
          '%$query%',
          '%$query%',
        ],
      );
    }

    final filtered = records.where((row) {

      final month = int.tryParse(
            row['month'].toString(),
          ) ??
          0;

      return month >= startMonth &&
          month <= endMonth;

    }).toList();

    if (filtered.isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "لا توجد بيانات مطابقة",
          ),
        ),
      );

      return;
    }

    // =========================
    // الخط العربي
    // =========================

    final font = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      ),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,

        build: (context) {

          return pw.Directionality(
            textDirection:
                pw.TextDirection.rtl,

            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [

                pw.Center(
                  child: pw.Text(
                    "تقرير الموارد البشرية",

                    style: pw.TextStyle(
                      font: font,
                      fontSize: 20,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  "السنة: $selectedYear",
                  style: pw.TextStyle(font: font),
                ),

                pw.Text(
                  "الفترة: $fromMonth → $toMonth",
                  style: pw.TextStyle(font: font),
                ),

                if (query.isNotEmpty)
                  pw.Text(
                    "البحث: $query",
                    style: pw.TextStyle(font: font),
                  ),

                pw.SizedBox(height: 15),

                pw.TableHelper.fromTextArray(

                  headerStyle:
                      pw.TextStyle(font: font),

                  cellStyle:
                      pw.TextStyle(font: font),

                  headers: [
                    "الرقم",
                    "الاسم",
                    "الرتبة",
                    "الوحدة",
                    "الحالة",
                    "الشهر",
                    "السنة",
                  ],

                  data: filtered.map((r) {

                    return [

                      r['number']
                              ?.toString() ??
                          '',

                      r['name']
                              ?.toString() ??
                          '',

                      r['rank']
                              ?.toString() ??
                          '',

                      r['unit']
                              ?.toString() ??
                          '',

                      r['status']
                              ?.toString() ??
                          '',

                      r['month']
                              ?.toString() ??
                          '',

                      r['year']
                              ?.toString() ??
                          '',
                    ];

                  }).toList(),
                ),

                pw.SizedBox(height: 30),

                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,

                  children: [

                    pw.Text(
                      "التوقيع: __________",
                      style: pw.TextStyle(font: font),
                    ),

                    pw.Text(
                      "التوقيع: __________",
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final dir =
        await getTemporaryDirectory();

    final file = File(
      "${dir.path}/hr_report.pdf",
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    await OpenFile.open(file.path);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "تم إنشاء التقرير بنجاح",
        ),
      ),
    );
  }
}
