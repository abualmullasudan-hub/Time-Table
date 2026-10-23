import 'package:flutter/material.dart';
import '../data.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  static const _keys = [kAssemblyKey, kBreakfastKey, kPrayerKey];

  String _label(String key) {
    if (key == kAssemblyKey) return 'الطابور';
    if (key == kBreakfastKey) return 'الفطور';
    return 'الصلاة';
  }

  Future<void> _edit(BuildContext context, int day, String key) async {
    final s = AppStore.instance;
    final controller =
        TextEditingController(text: s.activityAt(day, key).title);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${kDayNames[day]} • ${_label(key)}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            labelText: 'اسم النشاط',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      s.setActivity(day, key, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال الأنشطة'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: kDayCount,
        itemBuilder: (context, day) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(kDayNames[day],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                ..._keys.map((k) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.event_note,
                          color: Colors.deepOrange, size: 20),
                      title: Text(_label(k)),
                      subtitle: Text(s.activityAt(day, k).title),
                      trailing: const Icon(Icons.edit, size: 18),
                      onTap: () => _edit(context, day, k),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
