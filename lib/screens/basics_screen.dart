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
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات وإدارة الفصول'),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'المدرسة'),
              Tab(text: 'الفصول'),
              Tab(text: 'المعلمون'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: s,
          builder: (context, _) {
            return TabBarView(
              children: [
                // 1. تبويب المدرسة
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(controller: _schoolNameCtrl, decoration: const InputDecoration(labelText: 'اسم المدرسة', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _yearCtrl, decoration: const InputDecoration(labelText: 'العام الدراسي', border: OutlineInputBorder())),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () {
                          s.setSchoolInfo(_schoolNameCtrl.text, _yearCtrl.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح')));
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ الإعدادات'),
                      ),
                    ],
                  ),
                ),
                
                // 2. تبويب الفصول
                ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FilledButton.icon(
                      onPressed: () => _showClassDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة فصل جديد'),
                    ),
                    const SizedBox(height: 12),
                    ...s.classes.map((c) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.groups, color: Colors.teal),
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
                      onPressed: () => _askName(context, 'إضافة معلم', (name) => s.addTeacher(name)),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة معلم جديد'),
                    ),
                    const SizedBox(height: 12),
                    ...s.teachers.map((t) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.indigo),
                        title: Text(t.name),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => s.removeTeacher(t.id)),
                      ),
                    )),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  // نافذة إضافة/تعديل الفصل
  void _showClassDialog(BuildContext context, {SchoolClass? c}) {
    final nameCtrl = TextEditingController(text: c?.name ?? '');
    String level = c?.level ?? 'ابتدائي';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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

  // نافذة إضافة معلم
  void _askName(BuildContext context, String title, Function(String) onSave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () { 
              if (ctrl.text.isNotEmpty) { 
                onSave(ctrl.text); 
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
