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

  IconData _icon(String key) {
    if (key == kAssemblyKey) return Icons.flag;
    if (key == kBreakfastKey) return Icons.coffee;
    return Icons.mosque;
  }

  Future<void> _edit(BuildContext context, int day, String key) async {
    final s = AppStore.instance;
    final act = s.activityAt(day, key);
    final controller = TextEditingController(text: act.title);
    
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius)),
        title: Text('${kDayNames[day]} • ${_label(key)}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            labelText: 'اسم النشاط',
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
      // الحفاظ على أوقات البداية والنهاية وتحديث الاسم فقط
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
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kDayCount,
            itemBuilder: (context, day) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Icon(Icons.today, color: s.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              kDayNames[day],
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16 * s.fontScale,
                                color: s.isDarkMode ? Colors.white : s.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: s.isDarkMode ? Colors.white12 : Colors.grey.shade300),
                      ..._keys.map((k) => ListTile(
                            leading: Icon(_icon(k), color: s.primaryColor),
                            title: Text(_label(k), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              s.activityAt(day, k).title, 
                              style: TextStyle(color: s.isDarkMode ? Colors.white70 : Colors.black54)
                            ),
                            trailing: Icon(Icons.edit, size: 20, color: s.isDarkMode ? Colors.white54 : Colors.grey),
                            onTap: () => _edit(context, day, k),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
