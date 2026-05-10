import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class ReportsArchiveScreen extends StatefulWidget {
  const ReportsArchiveScreen({super.key});

  @override
  State<ReportsArchiveScreen> createState() => _ReportsArchiveScreenState();
}

class _ReportsArchiveScreenState extends State<ReportsArchiveScreen> {
  List<File> allFiles = [];
  List<File> filteredFiles = [];

  String searchQuery = "";
  String selectedMonth = "الكل";

  List<String> months = ["الكل"];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .where((f) => f.path.endsWith(".pdf"))
        .map((f) => File(f.path))
        .toList();

    // استخراج الشهور من أسماء الملفات
    Set<String> extractedMonths = {"الكل"};

    for (var f in files) {
      final name = f.path.split("/").last;

      // نحاول استخراج الشهر من الاسم
      final parts = name.split("_");
      for (var p in parts) {
        if (p.contains("2026") || p.contains("2025")) {
          extractedMonths.add(p);
        }
      }
    }

    setState(() {
      allFiles = files.reversed.toList();
      filteredFiles = allFiles;
      months = extractedMonths.toList();
    });
  }

  void filterFiles() {
    setState(() {
      filteredFiles = allFiles.where((file) {
        final name = file.path.toLowerCase();

        final matchSearch = name.contains(searchQuery.toLowerCase());

        final matchMonth = selectedMonth == "الكل"
            ? true
            : name.contains(selectedMonth);

        return matchSearch && matchMonth;
      }).toList();
    });
  }

  void openFile(File file) {
    OpenFile.open(file.path);
  }

  void shareFile(File file) {
    Share.shareXFiles([XFile(file.path)], text: "تقرير مباينة");
  }

  Future<void> deleteFile(File file) async {
    await file.delete();
    loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("📁 الأرشيف الذكي"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadFiles,
          ),
        ],
      ),

      body: Column(
        children: [

          // 🔍 البحث
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "بحث عن تقرير",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                filterFiles();
              },
            ),
          ),

          // 📅 الفلترة بالشهر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: selectedMonth,
              isExpanded: true,
              items: months
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                  filterFiles();
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📁 القائمة
          Expanded(
            child: filteredFiles.isEmpty
                ? const Center(
                    child: Text("لا توجد تقارير"),
                  )
                : ListView.builder(
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];
                      final name = file.path.split("/").last;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          title: Text(name),

                          subtitle: Text(
                            "📅 تقرير محفوظ",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: const Icon(Icons.open_in_new,
                                    color: Colors.blue),
                                onPressed: () => openFile(file),
                              ),

                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: Colors.green),
                                onPressed: () => shareFile(file),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => deleteFile(file),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
