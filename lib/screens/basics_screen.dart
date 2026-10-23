import 'package:flutter/material.dart';
import '../data.dart';

class BasicsScreen extends StatefulWidget {
  const BasicsScreen({super.key});

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen> {
  Future<String?> _askName(String title, String initial) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'الاسم', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('حفظ')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('المعلمون والفصول'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text('الفصول',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          ...s.classes.map((c) => ListTile(
                leading: const Icon(Icons.groups, color: Colors.teal),
                title: Text(c.name),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () async {
                  final name = await _askName('تعديل اسم الفصل', c.name);
                  if (name != null && name.isNotEmpty) {
                    setState(() => s.renameClass(c.id, name));
                  }
                },
              )),
          const Divider(height: 24),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text('المعلمون',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          ...s.teachers.map((t) => ListTile(
                leading: const Icon(Icons.person, color: Colors.indigo),
                title: Text(t.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () async {
                        final name = await _askName('تعديل اسم المعلم', t.name);
                        if (name != null && name.isNotEmpty) {
                          setState(() => s.renameTeacher(t.id, name));
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () =>
                          setState(() => s.removeTeacher(t.id)),
                    ),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () async {
                final name = await _askName('إضافة معلم', '');
                if (name != null && name.isNotEmpty) {
                  setState(() => s.addTeacher(name));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة معلم'),
            ),
          ),
        ],
      ),
    );
  }
}
