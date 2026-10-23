import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _soundEnabled = true;
  bool _visualEnabled = true;
  String _visualStyle = 'بطاقة عائمة'; 
  bool _alertBefore = true;
  bool _alertAfter = false;

  void _playSound() {
    if (!_soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  void _testVisualAlert() {
    if (!_visualEnabled) return;
    
    // حفظ المتغير قبل التأخير الزمني لتجنب الخطأ
    final messenger = ScaffoldMessenger.of(context);

    if (_visualStyle == 'شريط') {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: const Text('تنبيه تجريبي: الحصة القادمة بعد 3 دقائق', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.notifications, color: Colors.orange),
          actions: [TextButton(onPressed: () => messenger.hideCurrentMaterialBanner(), child: const Text('إغلاق'))],
        ),
      );
      Future.delayed(const Duration(seconds: 3), () => messenger.hideCurrentMaterialBanner());
    } else if (_visualStyle == 'بطاقة عائمة') {
      messenger.showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 8), Text('تنبيه تجريبي: الحصة القادمة بعد 3 دقائق')]),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(children: [Icon(Icons.notifications_active, color: Colors.orange), SizedBox(width: 8), Text('تنبيه')]),
          content: const Text('تنبيه تجريبي: الحصة القادمة بعد 3 دقائق'),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً'))],
        ),
      );
    }
    _playSound();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    final today = todaySchoolIndex();
    
    final todayLessons = s.lessons.values
        .where((l) => l.day == today)
        .toList()
      ..sort((a, b) => a.lessonIndex.compareTo(b.lessonIndex));

    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات والحصص'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.amber),
            onPressed: _testVisualAlert,
            tooltip: 'تجربة التنبيه',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إعدادات التنبيهات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('تنبيه صوتي'),
                    subtitle: const Text('تشغيل صوت عند بداية/نهاية الحصة'),
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                    secondary: const Icon(Icons.volume_up, color: Colors.blue),
                  ),
                  SwitchListTile(
                    title: const Text('تنبيه مرئي'),
                    subtitle: const Text('عرض إشعار على الشاشة'),
                    value: _visualEnabled,
                    onChanged: (v) => setState(() => _visualEnabled = v),
                    secondary: const Icon(Icons.visibility, color: Colors.blue),
                  ),
                  if (_visualEnabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: _visualStyle,
                        decoration: const InputDecoration(labelText: 'طريقة ظهور التنبيه المرئي', isDense: true),
                        items: ['شريط', 'بطاقة عائمة', 'نافذة منبثقة'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _visualStyle = v!),
                      ),
                    ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('تنبيه قبل الحصة بـ 3 دقائق'),
                    value: _alertBefore,
                    onChanged: (v) => setState(() => _alertBefore = v),
                    secondary: const Icon(Icons.timer, color: Colors.orange),
                  ),
                  SwitchListTile(
                    title: const Text('تنبيه عند نهاية الحصة'),
                    value: _alertAfter,
                    onChanged: (v) => setState(() => _alertAfter = v),
                    secondary: const Icon(Icons.timer_off, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('جدول حصص اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (today < 0)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('اليوم ليس يوم دراسي 🎉', style: TextStyle(fontSize: 18))),
            )
          else if (todayLessons.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('لا توجد حصص مسجلة لهذا اليوم', style: TextStyle(fontSize: 16))),
            )
          else
            ...todayLessons.map((l) {
              final time = s.times[l.lessonIndex];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text('${l.lessonIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(l.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s.className(l.classId)} | ${time.label}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.indigo),
                    onPressed: _playSound,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
