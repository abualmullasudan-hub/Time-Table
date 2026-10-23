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
  String? _classId;

  @override
  void initState() {
    super.initState();
    final s = AppStore.instance;
    if (s.classes.isNotEmpty) {
      _classId = s.classes.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإدخال السريع للحصص'),
        backgroundColor: s.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          if (s.classes.isEmpty) {
            return const Center(child: Text('يرجى إضافة فصول أولاً من الإعدادات'));
          }

          return Column(
            children: [
              // اختيار الفصل
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: s.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: DropdownButtonFormField<String>(
                  value: _classId,
                  decoration: InputDecoration(
                    labelText: 'اختر الفصل المراد إدخال جدوله',
                    prefixIcon: const Icon(Icons.groups),
                    isDense: true,
                    fillColor: s.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F7FA),
                  ),
                  items: s.classes
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _classId = v!),
                ),
              ),
              
              // جدول الإدخال
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kDayCount,
                  itemBuilder: (context, day) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.today, color: s.primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  kDayNames[day],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16 * s.fontScale,
                                    color: s.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: s.isDarkMode ? Colors.white12 : Colors.grey.shade300),
                            const SizedBox(height: 8),
                            
                            // شبكة الحصص
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(kLessonCount, (i) {
                                final l = _classId == null ? null : s.lessonAt(day, i, _classId!);
                                return SizedBox(
                                  width: 100,
                                  child: Column(
                                    children: [
                                      Text(
                                        'حصة ${i + 1}',
                                        style: TextStyle(
                                          fontSize: 11 * s.fontScale,
                                          fontWeight: FontWeight.bold,
                                          color: s.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      LessonBox(
                                        lesson: l,
                                        subtitle: l == null ? null : s.teacherName(l.teacherId),
                                        height: 70,
                                        onTap: () async {
                                          if (_classId == null) return;
                                          // استخدام Bottom Sheet بدلاً من نافذة في المنتصف
                                          await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
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
          );
        }
      ),
    );
  }
}
