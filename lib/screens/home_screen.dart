import 'package:flutter/material.dart';
import 'timetable_screen.dart';
import 'lessons_entry_screen.dart';
import 'times_screen.dart';
import 'basics_screen.dart';
import 'notifications_screen.dart';
import 'activities_screen.dart';
import 'theme_settings_screen.dart';
import '../data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    
    // تم إضافة ListenableBuilder هنا لضمان تحديث الشاشة فور حفظ البيانات
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('أهلاً بك 👋', style: TextStyle(fontSize: 16, color: s.isDarkMode ? Colors.white70 : Colors.grey, fontWeight: FontWeight.w600)),
                            Text(s.schoolName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: s.isDarkMode ? Colors.white : s.primaryColor)),
                          ],
                        ),
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: s.primaryColor.withOpacity(0.1),
                          child: Icon(Icons.school, color: s.primaryColor, size: 30),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [s.primaryColor, s.primaryColor.withOpacity(0.7)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(s.uiRadius + 8),
                        boxShadow: [
                          BoxShadow(color: s.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: _buildNextLessonCard(s),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.05,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildActionCard(context, Icons.person_pin, 'جدول المعلم', const Color(0xFF4F46E5), () => _go(context, const TimetableScreen(teacherMode: true))),
                      _buildActionCard(context, Icons.grid_view_rounded, 'جداول الفصول', const Color(0xFF0D9488), () => _go(context, const TimetableScreen(teacherMode: false))),
                      _buildActionCard(context, Icons.edit_calendar, 'إدخال الحصص', const Color(0xFFEA580C), () => _go(context, const LessonsEntryScreen())),
                      _buildActionCard(context, Icons.schedule, 'إدارة الأوقات', const Color(0xFF475569), () => _go(context, const TimesScreen())),
                      _buildActionCard(context, Icons.notifications_active, 'التنبيهات', const Color(0xFFE11D48), () => _go(context, const NotificationsScreen())),
                      _buildActionCard(context, Icons.free_breakfast, 'الأنشطة', const Color(0xFFD97706), () => _go(context, const ActivitiesScreen())),
                      _buildActionCard(context, Icons.palette, 'تخصيص المظهر', const Color(0xFF9333EA), () => _go(context, const ThemeSettingsScreen())),
                      _buildActionCard(context, Icons.settings, 'الإعدادات', const Color(0xFF64748B), () => _go(context, const BasicsScreen())),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildNextLessonCard(AppStore s) {
    final today = todaySchoolIndex();
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    
    Lesson? nextLesson;
    String status = 'عطلة سعيدة 🎉';

    if (today >= 0) {
      for (var l in s.lessons.values) {
        if (l.day == today) {
          final t = s.times[l.lessonIndex];
          if (nowMin <= t.endMinutes) {
            nextLesson = l;
            status = nowMin >= t.startMinutes ? 'الحصة الحالية' : 'الحصة القادمة';
            break;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(status, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
            if (nextLesson != null)
              Text(s.times[nextLesson.lessonIndex].label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        if (nextLesson != null) ...[
          Text(nextLesson.subject, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(s.className(nextLesson.classId), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Text(s.teacherName(nextLesson.teacherId), style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ] else
          const Text('لا توجد حصص متبقية اليوم', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _go(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _buildActionCard(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final s = AppStore.instance;
    return Container(
      decoration: BoxDecoration(
        color: s.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(s.uiRadius),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(s.uiRadius),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15, 
                  color: s.isDarkMode ? Colors.white : const Color(0xFF1E293B)
                ), 
                textAlign: TextAlign.center
              ),
            ],
          ),
        ),
      ),
    );
  }
}
