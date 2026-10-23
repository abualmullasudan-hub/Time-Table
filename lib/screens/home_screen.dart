import 'package:flutter/material.dart';
import 'timetable_screen.dart';
import 'lessons_entry_screen.dart';
import 'activities_screen.dart';
import 'times_screen.dart';
import 'basics_screen.dart';
import 'notifications_screen.dart';
import '../data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    // استخدام ListenableBuilder ليتم تحديث الشاشة فوراً عند تغيير الإعدادات أو الألوان
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppBar(
            title: const Text('جدول الحصص'),
            centerTitle: true,
            backgroundColor: s.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              // ترويسة المدرسة الاحترافية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                decoration: BoxDecoration(
                  color: s.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24), 
                    bottomRight: Radius.circular(24)
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      s.schoolName, 
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.academicYear, 
                      style: const TextStyle(color: Colors.white70, fontSize: 14)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _tile(context, Icons.person_pin, 'جدول المعلم', Colors.indigo,
                        () => _go(context, const TimetableScreen(teacherMode: true))),
                    _tile(context, Icons.grid_view_rounded, 'جداول الفصول', Colors.teal,
                        () => _go(context, const TimetableScreen(teacherMode: false))),
                    _tile(context, Icons.edit_note, 'إدخال الحصص', Colors.orange,
                        () => _go(context, const LessonsEntryScreen())),
                    _tile(context, Icons.free_breakfast, 'الأنشطة', Colors.deepOrange,
                        () => _go(context, const ActivitiesScreen())),
                    _tile(context, Icons.schedule, 'زمن الحصص', Colors.blueGrey,
                        () => _go(context, const TimesScreen())),
                    _tile(context, Icons.settings, 'الإعدادات والفصول', Colors.purple,
                        () => _go(context, const BasicsScreen())),
                    _tile(context, Icons.notifications_active, 'التنبيهات', Colors.redAccent,
                        () => _go(context, const NotificationsScreen())),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _go(BuildContext context, Widget page) => 
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _tile(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
