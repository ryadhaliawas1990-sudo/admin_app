import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../features/pdf/person_timeline_pdf.dart';

class PersonTimelineScreen extends StatefulWidget {

  final String number;
  final String name;

  const PersonTimelineScreen({
    super.key,
    required this.number,
    required this.name,
  });

  @override
  State<PersonTimelineScreen> createState() =>
      _PersonTimelineScreenState();
}

class _PersonTimelineScreenState
    extends State<PersonTimelineScreen> {

  List<Map<String, dynamic>> timeline = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    final data =
        await DBHelper.getPersonTimeline(widget.number);

    setState(() {
      timeline = data;
    });
  }

  Future<void> exportPdf() async {

    if (timeline.isEmpty) {
      return;
    }

    final first = timeline.first;

    await PersonTimelinePdf.generate(

      name: widget.name,
      number: widget.number,

      rank:
          first['rank']?.toString() ?? '',

      unit:
          first['unit']?.toString() ?? '',

      timeline: timeline,

      topText:
          'سجل الحالة للفرد',

      rightSign:
          'توقيع المسؤول',

      leftSign:
          'الختم',
    );
  }

  @override
  Widget build(BuildContext context) {

    String rank = '';
    String unit = '';

    if (timeline.isNotEmpty) {

      rank =
          timeline.first['rank'] ?? '';

      unit =
          timeline.first['unit'] ?? '';
    }

    return Scaffold(

      appBar: AppBar(

        title:
            const Text('سجل الحالة'),

        actions: [

          IconButton(

            icon:
                const Icon(Icons.picture_as_pdf),

            onPressed: exportPdf,
          ),
        ],
      ),

      body: timeline.isEmpty

          ? const Center(
              child:
                  Text('لا توجد بيانات'),
            )

          : Padding(

              padding:
                  const EdgeInsets.all(12),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // معلومات الشخص
                  Card(

                    child: Padding(

                      padding:
                          const EdgeInsets.all(12),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            'الاسم: ${widget.name}',

                            style:
                                const TextStyle(

                              fontSize: 18,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'الرقم: ${widget.number}',
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'الرتبة: $rank',
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            'الوحدة: $unit',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(

                    'السجل الزمني',

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // الجدول
                  Expanded(

                    child:
                        SingleChildScrollView(

                      scrollDirection:
                          Axis.horizontal,

                      child: DataTable(

                        columns: const [

                          DataColumn(
                            label:
                                Text('السنة'),
                          ),

                          DataColumn(
                            label:
                                Text('الشهر'),
                          ),

                          DataColumn(
                            label:
                                Text('الحالة'),
                          ),
                        ],

                        rows:
                            timeline.map((item) {

                          return DataRow(

                            cells: [

                              DataCell(

                                Text(

                                  item['year']
                                          ?.toString() ??
                                      '',
                                ),
                              ),

                              DataCell(

                                Text(

                                  item['month']
                                          ?.toString() ??
                                      '',
                                ),
                              ),

                              DataCell(

                                Text(

                                  item['status']
                                          ?.toString() ??
                                      '',
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
