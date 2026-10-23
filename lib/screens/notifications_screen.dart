import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _visualStyle = 'بطاقة عائمة';

  void _playSound() {
    SystemSound.play(SystemSoundType.alert);
  }

  void _showVisualAlert(String message) {
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
            borderRadius: BorderRadius.circular(s.uiRadius),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius)),
          duration: duration,
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
                  Divider(color: s.isDarkMode ? Colors.white12 : Colors.grey.shade300, height: 24),
                  
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
                    activeColor: s.primaryColor,
                    onChanged: (v) {
                      s.setAlertSettings(v.round(), s.smartNotificationsEnabled);
                    },
                  ),

                  Divider(color: s.isDarkMode ? Colors.white12 : Colors.grey.shade300, height: 24),
                  
                  SwitchListTile(
                    title: const Text('التنبيهات الذكية أثناء الأنشطة'),
                    subtitle: const Text('عرض الحصص المتبقية عند الفطور أو الصلاة'),
                    value: s.smartNotificationsEnabled,
                    activeColor: s.primaryColor,
                    onChanged: (v) {
                      s.setAlertSettings(s.alertDurationSeconds, v);
                    },
                    secondary: Icon(Icons.psychology, color: s.primaryColor),
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
