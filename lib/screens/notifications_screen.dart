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

  void _showVisualAlert(String message) {
    if (!_visualEnabled) return;

    final s = AppStore.instance;
    final duration = Duration(seconds: s.alertDurationSeconds);
    final messenger = ScaffoldMessenger.of(context);

    // إغلاق أي تنبيه سابق
    messenger.hideCurrentMaterialBanner();
    messenger.hideCurrentSnackBar();

    if (_visualStyle == 'شريط ثابت') {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: Icon(Icons.notifications, color: s.primaryColor),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: const Text('إغلاق'),
            )
          ],
        ),
      );
    } 
    else if (_visualStyle == 'شريط متحرك') {
      OverlayState? overlayState = Overlay.of(context);
      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: s.primaryColor,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message, 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      overlayState.insert(overlayEntry);
      Future.delayed(duration, () {
        try { overlayEntry.remove(); } catch (_) {}
      });
    }
    else if (_visualStyle == 'شريط يظهر ويختفي') {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: Icon(Icons.notifications, color: s.primaryColor),
          actions: [
            TextButton(
              onPressed: () => messenger.hideCurrentMaterialBanner(),
              child: const Text('إغلاق'),
            )
          ],
        ),
      );
      Future.delayed(duration, () {
        messenger.hideCurrentMaterialBanner();
      });
    } 
    else if (_visualStyle == 'بطاقة عائمة') {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white), 
              const SizedBox(width: 8), 
              Expanded(child: Text(message))
            ]
          ),
          backgroundColor: s.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: duration,
        ),
      );
    }
    _playSound();
  }

  void _simulateSmartAlert() {
    final s = AppStore.instance;
    final today = todaySchoolIndex();
    if (today < 0) {
      _showVisualAlert('اليوم ليس يوم دراسي 🎉');
      return;
    }

    final todayLessons = s.lessons.values
        .where((l) => l.day == today)
        .toList()
      ..sort((a, b) => a.lessonIndex.compareTo(b.lessonIndex));

    if (todayLessons.isEmpty) {
      _showVisualAlert('لا توجد حصص مسجلة لهذا اليوم');
    } else {
      final nextLesson = todayLessons.first;
      final remaining = todayLessons.length;
      _showVisualAlert('تنبيه ذكي: متبقي $remaining حصص اليوم. الحصة القادمة: ${nextLesson.subject} (${s.className(nextLesson.classId)})');
    }
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
        title: const Text('إدارة التنبيهات'),
        backgroundColor: s.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.amber),
            onPressed: () => _showVisualAlert('هذا تنبيه تجريبي مرئي وصوتي'),
            tooltip: 'تجربة التنبيه',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // إعدادات التنبيهات
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings_suggest, color: s.primaryColor),
                      const SizedBox(width: 8),
                      const Text('تخصيص التنبيهات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  SwitchListTile(
                    title: const Text('التنبيه الصوتي'),
                    subtitle: const Text('تشغيل نغمة النظام عند التنبيه'),
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                    secondary: Icon(Icons.volume_up, color: s.primaryColor),
                  ),
                  
                  SwitchListTile(
                    title: const Text('التنبيه المرئي'),
                    subtitle: const Text('عرض إشعار على الشاشة'),
                    value: _visualEnabled,
                    onChanged: (v) => setState(() => _visualEnabled = v),
                    secondary: Icon(Icons.visibility, color: s.primaryColor),
                  ),
                  
                  if (_visualEnabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        value: _visualStyle,
                        decoration: const InputDecoration(labelText: 'شكل التنبيه المرئي', isDense: true),
                        items: ['شريط ثابت', 'شريط متحرك', 'شريط يظهر ويختفي', 'بطاقة عائمة']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _visualStyle = v!),
                      ),
                    ),
                  
                  if (_visualEnabled) ...[
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('مدة عرض التنبيه (بالثواني)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Slider(
                      value: s.alertDurationSeconds.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '${s.alertDurationSeconds} ثوانٍ',
                      onChanged: (v) {
                        s.setAlertSettings(v.round(), s.smartNotificationsEnabled);
                      },
                    ),
                  ],

                  const Divider(height: 24),
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

                  const Divider(height: 24),
                  
                  SwitchListTile(
                    title: const Text('التنبيهات الذكية أثناء الأنشطة'),
                    subtitle: const Text('عرض الحصص المتبقية عند الفطور أو الصلاة'),
                    value: s.smartNotificationsEnabled,
                    onChanged: (v) {
                      s.setAlertSettings(s.alertDurationSeconds, v);
                    },
                    secondary: Icon(Icons.psychology, color: s.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _simulateSmartAlert,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('تجربة التنبيه الذكي (محاكاة وقت النشاط)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: s.primaryColor,
                        side: BorderSide(color: s.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('حصص اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (today < 0)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('اليوم ليس يوم دراسي 🎉', style: TextStyle(fontSize: 16, color: Colors.grey))),
            )
          else if (todayLessons.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('لا توجد حصص مسجلة لهذا اليوم', style: TextStyle(fontSize: 16, color: Colors.grey))),
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
                    onPressed: () => _showVisualAlert('تذكير: حصة ${l.subject} مع ${s.teacherName(l.teacherId)}'),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
