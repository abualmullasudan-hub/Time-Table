import 'package:flutter/material.dart';
import 'timetable_screen.dart';
import 'lessons_entry_screen.dart';
import 'activities_screen.dart';
import 'times_screen.dart';
import 'basics_screen.dart';
import 'notifications_screen.dart'; // تمت إضافة هذا السطر

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الحصص المدرسية'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _tile(context, Icons.person_pin, 'جدول المعلم', Colors.indigo,
                () => _go(context, const TimetableScreen(teacherMode: true))),
            _tile(context, Icons.grid_view_rounded, 'جدول الفصل', Colors.teal,
                () => _go(context, const TimetableScreen(teacherMode: false))),
            _tile(context, Icons.edit_note, 'إدخال الحصص', Colors.orange,
                () => _go(context, const LessonsEntryScreen())),
            _tile(context, Icons.free_breakfast, 'إدخال الأنشطة',
                Colors.deepOrange, () => _go(context, const ActivitiesScreen())),
            _tile(context, Icons.schedule, 'زمن الحصص', Colors.blueGrey,
                () => _go(context, const TimesScreen())),
            _tile(context, Icons.groups, 'المعلمون والفصول', Colors.purple,
                () => _go(context, const BasicsScreen())),
            // الزر الجديد للتنبيهات
            _tile(context, Icons.notifications, 'التنبيهات', Colors.redAccent,
                () => _go(context, const NotificationsScreen())),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _tile(BuildContext context, IconData icon, String label, Color color,
      VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
