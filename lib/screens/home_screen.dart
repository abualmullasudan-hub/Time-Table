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
    
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              // ترويسة المدرسة الاحترافية
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: s.primaryColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: s.primaryColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30), 
                        bottomRight: Radius.circular(30)
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.school, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.schoolName, 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 22 * s.fontScale, 
                              fontWeight: s.fontWeight == FontWeight.bold ? FontWeight.bold : FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.academicYear, 
                            style: TextStyle(color: Colors.white70, fontSize: 14 * s.fontScale),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // شبكة الأزرار
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _tile(context, Icons.person_pin, 'جدول المعلم', Colors.indigo,
                        () => _go(context, const TimetableScreen(teacherMode: true))),
                    _tile(context, Icons.grid_view_rounded, 'جداول الفصول', Colors.teal,
                        () => _go(context, const TimetableScreen(teacherMode: false))),
                    _tile(context, Icons.edit_note, 'إدخال الحصص', Colors.orange,
                        () => _go(context, const LessonsEntryScreen())),
                    _tile(context, Icons.schedule, 'إدارة الأوقات', Colors.blueGrey,
                        () => _go(context, const TimesScreen())),
                    _tile(context, Icons.notifications_active, 'التنبيهات', Colors.redAccent,
                        () => _go(context, const NotificationsScreen())),
                    _tile(context, Icons.settings, 'الإعدادات', Colors.purple,
                        () => _go(context, const BasicsScreen())),
                    // الزر السابع (الأنشطة) تم دمجه في إدارة الأوقات، ولكن نترك زراً سريعاً للأنشطة إذا أردت
                    _tile(context, Icons.free_breakfast, 'الأنشطة', Colors.deepOrange,
                        () => _go(context, const ActivitiesScreen())),
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
    final s = AppStore.instance;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 15 * s.fontScale,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
