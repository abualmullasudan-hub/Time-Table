import 'package:flutter/material.dart';
import '../data.dart';
import '../widgets/lesson_box.dart';
import '../widgets/lesson_dialog.dart';

class LessonsEntryScreen extends StatefulWidget {
  const LessonsEntryScreen({super.key});

  @override
  State<LessonsEntryScreen> createState() => _LessonsEntryScreenState();
}

class _LessonsEntryScreenState extends State<LessonsEntryScreen> {
  late String _classId;

  @override
  void initState() {
    super.initState();
    _classId = AppStore.instance.classes.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال الحصص'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _classId,
              decoration: const InputDecoration(
                labelText: 'الفصل',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: s.classes
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _classId = v!),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              itemCount: kDayCount,
              itemBuilder: (context, day) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kDayNames[day],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(kLessonCount, (i) {
                            final l = s.lessonAt(day, i, _classId);
                            return SizedBox(
                              width: 96,
                              child: Column(
                                children: [
                                  Text('حصة ${i + 1}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blueGrey.shade600)),
                                  const SizedBox(height: 2),
                                  LessonBox(
                                    lesson: l,
                                    subtitle:
                                        l == null ? null : s.teacherName(l.teacherId),
                                    onTap: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (_) => LessonDialog(
                                          day: day,
                                          lessonIndex: i,
                                          existing: l,
                                          fixedClassId: _classId,
                                        ),
                                      );
                                      if (mounted) setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
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
