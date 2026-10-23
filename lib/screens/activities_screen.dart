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
    final act = s.activityAt(day, key);
    final controller = TextEditingController(text: act.title);
    
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
      // تم تحديث الدالة لتشمل وقت البداية والنهاية الموجودين مسبقاً
      s.setActivity(day, key, result, act.start, act.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('أسماء الأنشطة'),
        backgroundColor: s.primaryColor,
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
                      leading: Icon(Icons.event_note, color: s.primaryColor, size: 20),
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
