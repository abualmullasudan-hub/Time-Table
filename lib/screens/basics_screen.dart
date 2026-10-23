import 'package:flutter/material.dart';
import '../data.dart';

class BasicsScreen extends StatefulWidget {
  const BasicsScreen({super.key});

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> {
  final _schoolNameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _schoolNameCtrl.text = AppStore.instance.schoolName;
    _yearCtrl.text = AppStore.instance.academicYear;
  }

  @override
  void dispose() {
    _schoolNameCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات والتحكم'),
          backgroundColor: s.primaryColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'المدرسة', icon: Icon(Icons.school)),
              Tab(text: 'الفصول', icon: Icon(Icons.groups)),
              Tab(text: 'المعلمون', icon: Icon(Icons.person)),
              Tab(text: 'المواد', icon: Icon(Icons.book)),
              Tab(text: 'الخطوط', icon: Icon(Icons.text_fields)),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: s,
          builder: (context, _) {
            return TabBarView(
              children: [
                // 1. تبويب المدرسة
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('بيانات المدرسة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _schoolNameCtrl, 
                        decoration: const InputDecoration(labelText: 'اسم المدرسة', prefixIcon: Icon(Icons.school))
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _yearCtrl, 
                        decoration: const InputDecoration(labelText: 'العام الدراسي', prefixIcon: Icon(Icons.calendar_today))
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: s.primaryColor),
                          onPressed: () {
                            s.setSchoolInfo(_schoolNameCtrl.text, _yearCtrl.text);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ بيانات المدرسة بنجاح')));
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('حفظ البيانات'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 2. تبويب الفصول
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: s.primaryColor),
                      onPressed: () => _showClassDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة فصل جديد'),
                    ),
                    const SizedBox(height: 12),
                    ...s.classes.map((c) => Card(
                      child: ListTile(
                        leading: Icon(Icons.groups, color: s.primaryColor),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('المرحلة: ${c.level}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showClassDialog(context, c: c)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => s.removeClass(c.id)),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
                
                // 3. تبويب المعلمين
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: s.primaryColor),
                      onPressed: () => _showTeacherDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة معلم جديد'),
                    ),
                    const SizedBox(height: 12),
                    ...s.teachers.map((t) => Card(
                      child: ListTile(
                        leading: Icon(Icons.person, color: s.primaryColor),
                        title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('المواد: ${t.subjects.isEmpty ? "غير محددة" : t.subjects.join(", ")}'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => s.removeTeacher(t.id)),
                      ),
                    )),
                  ],
                ),

                // 4. تبويب المواد (الجديد)
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: s.primaryColor),
                      onPressed: () => _showSubjectDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة مادة جديدة'),
                    ),
                    const SizedBox(height: 12),
                    ...s.subjects.map((sub) => Card(
                      child: ListTile(
                        leading: Icon(Icons.book, color: s.primaryColor),
                        title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showSubjectDialog(context, sub: sub)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => s.removeSubject(sub.id)),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),

                // 5. تبويب الخطوط (الجديد)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('التحكم في حجم الخط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Slider(
                        value: s.fontScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: '${(s.fontScale * 100).toInt()}%',
                        onChanged: (v) {
                          s.setFontSettings(v, s.fontWeight);
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      const Text('سماكة الخط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SegmentedButton<FontWeight>(
                        segments: const [
                          ButtonSegment(value: FontWeight.normal, label: Text('عادي')),
                          ButtonSegment(value: FontWeight.bold, label: Text('عريض')),
                        ],
                        selected: {s.fontWeight},
                        onSelectionChanged: (Set<FontWeight> newSelection) {
                          s.setFontSettings(s.fontScale, newSelection.first);
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: s.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: s.primaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text('معاينة الخط', style: TextStyle(fontWeight: FontWeight.bold, color: s.primaryColor)),
                            const SizedBox(height: 10),
                            Text(
                              'هذا النص يوضح حجم وسماكة الخط الذي اخترته.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16 * s.fontScale, fontWeight: s.fontWeight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  // --- دوال النوافذ المنبثقة ---

  void _showClassDialog(BuildContext context, {SchoolClass? c}) {
    final nameCtrl = TextEditingController(text: c?.name ?? '');
    String level = c?.level ?? 'ابتدائي';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(c == null ? 'إضافة فصل' : 'تعديل الفصل'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl, 
                  decoration: const InputDecoration(labelText: 'اسم الفصل (مثال: أول أ)')
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: level,
                  decoration: const InputDecoration(labelText: 'المرحلة'),
                  items: ['ابتدائي', 'متوسط', 'ثانوي']
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => level = v!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    if (c == null) {
                      AppStore.instance.addClass(nameCtrl.text, level);
                    } else {
                      AppStore.instance.updateClass(c.id, nameCtrl.text, level);
                    }
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showTeacherDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    List<String> selectedSubjects = [];
    final s = AppStore.instance;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('إضافة معلم جديد'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl, 
                    decoration: const InputDecoration(labelText: 'اسم المعلم'),
                  ),
                  const SizedBox(height: 16),
                  const Text('اختر المواد التي يدرسها:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: s.subjects.map((sub) {
                          final isSelected = selectedSubjects.contains(sub.name);
                          return FilterChip(
                            label: Text(sub.name),
                            selected: isSelected,
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  selectedSubjects.add(sub.name);
                                } else {
                                  selectedSubjects.remove(sub.name);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              FilledButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    s.addTeacher(nameCtrl.text, selectedSubjects);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showSubjectDialog(BuildContext context, {Subject? sub}) {
    final nameCtrl = TextEditingController(text: sub?.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(sub == null ? 'إضافة مادة' : 'تعديل المادة'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'اسم المادة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                if (sub == null) {
                  AppStore.instance.addSubject(nameCtrl.text);
                } else {
                  AppStore.instance.updateSubject(sub.id, nameCtrl.text);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
