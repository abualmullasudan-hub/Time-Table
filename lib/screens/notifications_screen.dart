import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void _playSound() {
    SystemSound.play(SystemSoundType.alert);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تشغيل التنبيه الصوتي 🔔')),
    );
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
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: _playSound,
            tooltip: 'تجربة الصوت',
          )
        ],
      ),
      body: Column(
        children: [
          if (today < 0)
            const Expanded(
              child: Center(child: Text('اليوم ليس يوم دراسي 🎉', style: TextStyle(fontSize: 18))),
            )
          else if (todayLessons.isEmpty)
            const Expanded(
              child: Center(child: Text('لا توجد حصص مسجلة لهذا اليوم', style: TextStyle(fontSize: 16))),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: todayLessons.length,
                itemBuilder: (context, index) {
                  final l = todayLessons[index];
                  final time = s.times[l.lessonIndex];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text('${l.lessonIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text(l.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text('الفصل: ${s.className(l.classId)} | الأستاذ: ${s.teacherName(l.teacherId)}\nالوقت: ${time.label}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.notifications_active, color: Colors.orange),
                        onPressed: _playSound,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
