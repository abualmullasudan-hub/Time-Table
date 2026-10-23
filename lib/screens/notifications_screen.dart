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
  
  // الخيارات الأربعة المطلوبة
  String _visualStyle = 'بطاقة عائمة'; 
  bool _alertBefore = true;
  bool _alertAfter = false;

  void _playSound() {
    if (!_soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
  }

  void _testVisualAlert() {
    if (!_visualEnabled) return;
    
    final messenger = ScaffoldMessenger.of(context);

    // إغلاق أي تنبيه سابق
    messenger.hideCurrentMaterialBanner();
    messenger.hideCurrentSnackBar();

    if (_visualStyle == 'شريط ثابت') {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: const Text('تنبيه: الحصة القادمة بعد 3 دقائق', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.notifications, color: Colors.orange),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(), 
              child: const Text('إغلاق')
            )
          ],
        ),
      );
    } 
    else if (_visualStyle == 'شريط متحرك') {
      // إنشاء شريط ينسدل من أعلى الشاشة
      OverlayState? overlayState = Overlay.of(context);
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.amber.shade600,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تنبيه متحرك: الحصة القادمة بعد 3 دقائق', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      overlayState.insert(overlayEntry);
      // إزالة الشريط تلقائياً بعد 3 ثوانٍ
      Future.delayed(const Duration(seconds: 3), () {
        try { overlayEntry.remove(); } catch (_) {}
      });
    }
    else if (_visualStyle == 'شريط يظهر ويختفي') {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: const Text('تنبيه: الحصة القادمة بعد 3 دقائق', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.notifications, color: Colors.orange),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(), 
              child: const Text('إغلاق')
            )
          ],
        ),
      );
      // يختفي تلقائياً بعد 3 ثوانٍ
      Future.delayed(const Duration(seconds: 3), () {
        messenger.hideCurrentMaterialBanner();
      });
    } 
    else if (_visualStyle == 'بطاقة عائمة') {
      messenger.showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 8), Text('تنبيه: الحصة القادمة بعد 3 دقائق')]),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } 
    
    _playSound();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    final today = todaySchoolIndex();
    
    // جلب حصص اليوم وترتيبها
    final todayLessons = s.lessons.values
        .where((l) => l.day == today)
        .toList()
      ..sort((a, b) => a.lessonIndex.compareTo(b.lessonIndex));

    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات والحصص'),
        backgroundColor: s.primaryColor,
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
          // إعدادات التنبيهات
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
                    secondary: Icon(Icons.volume_up, color: s.primaryColor),
                  ),
                  SwitchListTile(
                    title: const Text('تنبيه مرئي'),
                    subtitle: const Text('عرض إشعار على الشاشة'),
                    value: _visualEnabled,
                    onChanged: (v) => setState(() => _visualEnabled = v),
                    secondary: Icon(Icons.visibility, color: s.primaryColor),
                  ),
                  if (_visualEnabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: _visualStyle,
                        decoration: const InputDecoration(labelText: 'طريقة ظهور التنبيه المرئي', isDense: true, border: OutlineInputBorder()),
                        items: ['شريط ثابت', 'شريط متحرك', 'شريط يظهر ويختفي', 'بطاقة عائمة']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
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

          // قائمة الحصص
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
                    backgroundColor: s.primaryColor.withOpacity(0.1),
                    child: Text('${l.lessonIndex + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: s.primaryColor)),
                  ),
                  title: Text(l.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s.className(l.classId)} | ${time.label}'),
                  trailing: IconButton(
                    icon: Icon(Icons.volume_up, color: s.primaryColor),
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
