import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const List<String> kDayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];
const int kDayCount = 5;
const int kLessonCount = 8;

const String kAssemblyKey = 'assembly';
const String kBreakfastKey = 'breakfast';
const String kPrayerKey = 'prayer';

String timeLabel(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final p = t.period == DayPeriod.am ? 'ص' : 'م';
  return '$h:$m $p';
}

int todaySchoolIndex() {
  switch (DateTime.now().weekday) {
    case DateTime.sunday: return 0;
    case DateTime.monday: return 1;
    case DateTime.tuesday: return 2;
    case DateTime.wednesday: return 3;
    case DateTime.thursday: return 4;
    default: return -1;
  }
}

class SlotTime {
  TimeOfDay start;
  TimeOfDay end;
  SlotTime(this.start, this.end);
  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;
  String get label => '${timeLabel(start)} - ${timeLabel(end)}';
}

class Subject {
  final String id;
  String name;
  Subject(this.id, this.name);
}

class SchoolClass {
  final String id;
  String name;
  String level; 
  SchoolClass(this.id, this.name, this.level);
}

class Teacher {
  final String id;
  String name;
  List<String> subjects; 
  Teacher(this.id, this.name, {this.subjects = const []});
}

class Lesson {
  final int day;
  final int lessonIndex;
  final String classId;
  String subject;
  String teacherId;

  Lesson({
    required this.day,
    required this.lessonIndex,
    required this.classId,
    required this.subject,
    required this.teacherId,
  });

  static String keyOf(int day, int lessonIndex, String classId) => '$day|$lessonIndex|$classId';
  String get key => keyOf(day, lessonIndex, classId);
}

class ActivitySlot {
  final int day;
  final String keyName;
  String title;
  TimeOfDay start;
  TimeOfDay end;

  ActivitySlot({
    required this.day, 
    required this.keyName, 
    required this.title,
    required this.start,
    required this.end,
  });
  
  static String keyOf(int day, String keyName) => '$day|$keyName';
  String get id => keyOf(day, keyName);
  String get timeLabelStr => '${timeLabel(start)} - ${timeLabel(end)}';
}

class AppStore extends ChangeNotifier {
  AppStore._() { _loadData(); }
  static final AppStore instance = AppStore._();

  // إعدادات المدرسة
  String schoolName = 'مدرسة النور';
  String academicYear = '1445 هـ - 2024 م';

  // الثيمات والألوان
  Color primaryColor = const Color(0xFF1565C0);
  Color tableHeaderColor = const Color(0xFFD6E4FF);
  Color tableSubHeaderColor = const Color(0xFFBBDEFB);

  // إعدادات الخطوط
  double fontScale = 1.0; // 0.8 أصغر، 1.2 أكبر
  FontWeight fontWeight = FontWeight.normal;

  // إعدادات التنبيهات
  int alertDurationSeconds = 3; // مدة بقاء التنبيه المرئي
  bool smartNotificationsEnabled = true; // تنبيهات الحصص المتبقية أثناء الأنشطة

  final List<Subject> subjects = [];
  final List<SchoolClass> classes = [];
  final List<Teacher> teachers = [];
  final List<SlotTime> times = [];
  final Map<String, Lesson> lessons = {};
  final Map<String, ActivitySlot> activities = {};

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString('app_data_v3');
    
    if (dataStr != null) {
      try {
        final data = jsonDecode(dataStr);
        schoolName = data['schoolName'] ?? 'مدرسة النور';
        academicYear = data['academicYear'] ?? '1445 هـ - 2024 م';
        primaryColor = Color(data['primaryColor'] ?? 0xFF1565C0);
        tableHeaderColor = Color(data['tableHeaderColor'] ?? 0xFFD6E4FF);
        tableSubHeaderColor = Color(data['tableSubHeaderColor'] ?? 0xFFBBDEFB);
        
        fontScale = data['fontScale'] ?? 1.0;
        alertDurationSeconds = data['alertDurationSeconds'] ?? 3;
        smartNotificationsEnabled = data['smartNotificationsEnabled'] ?? true;
        
        subjects.clear();
        if (data['subjects'] != null) {
          for (var s in data['subjects']) {
            subjects.add(Subject(s['id'], s['name']));
          }
        }
        
        classes.clear();
        for (var c in data['classes']) {
          classes.add(SchoolClass(c['id'], c['name'], c['level']));
        }
        
        teachers.clear();
        for (var t in data['teachers']) {
          List<String> subs = [];
          if (t['subjects'] != null) subs = List<String>.from(t['subjects']);
          teachers.add(Teacher(t['id'], t['name'], subjects: subs));
        }
        
        lessons.clear();
        for (var l in data['lessons']) {
          lessons[l['key']] = Lesson(
            day: l['day'], lessonIndex: l['lessonIndex'], classId: l['classId'],
            subject: l['subject'], teacherId: l['teacherId']
          );
        }
        
        activities.clear();
        if (data['activities'] != null) {
          for (var a in data['activities']) {
            activities[a['id']] = ActivitySlot(
              day: a['day'], keyName: a['keyName'], title: a['title'],
              start: TimeOfDay(hour: a['startH'], minute: a['startM']),
              end: TimeOfDay(hour: a['endH'], minute: a['endM']),
            );
          }
        }
      } catch (e) {
        _seed(); 
      }
    } else {
      _seed(); 
    }
    
    if (subjects.isEmpty) {
      subjects.addAll([
        Subject('s1', 'رياضيات'), Subject('s2', 'لغة عربية'), 
        Subject('s3', 'علوم'), Subject('s4', 'لغة إنجليزية'),
        Subject('s5', 'تربية إسلامية')
      ]);
    }
    
    _setupTimes();
    _setupActivities();
    notifyListeners();
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'schoolName': schoolName,
      'academicYear': academicYear,
      'primaryColor': primaryColor.value,
      'tableHeaderColor': tableHeaderColor.value,
      'tableSubHeaderColor': tableSubHeaderColor.value,
      'fontScale': fontScale,
      'alertDurationSeconds': alertDurationSeconds,
      'smartNotificationsEnabled': smartNotificationsEnabled,
      'subjects': subjects.map((s) => {'id': s.id, 'name': s.name}).toList(),
      'classes': classes.map((c) => {'id': c.id, 'name': c.name, 'level': c.level}).toList(),
      'teachers': teachers.map((t) => {'id': t.id, 'name': t.name, 'subjects': t.subjects}).toList(),
      'lessons': lessons.values.map((l) => {
        'key': l.key, 'day': l.day, 'lessonIndex': l.lessonIndex,
        'classId': l.classId, 'subject': l.subject, 'teacherId': l.teacherId
      }).toList(),
      'activities': activities.values.map((a) => {
        'id': a.id, 'day': a.day, 'keyName': a.keyName, 'title': a.title,
        'startH': a.start.hour, 'startM': a.start.minute,
        'endH': a.end.hour, 'endM': a.end.minute
      }).toList(),
    };
    await prefs.setString('app_data_v3', jsonEncode(data));
  }

  void _seed() {
    schoolName = 'مدرسة النور';
    academicYear = '1445 هـ';
    classes.add(SchoolClass('c1', 'أول أ', 'ابتدائي'));
    classes.add(SchoolClass('c2', 'أول ب', 'ابتدائي'));
    classes.add(SchoolClass('c3', 'ثاني أ', 'متوسط'));
    teachers.add(Teacher('t1', 'أ. أحمد', subjects: ['رياضيات', 'علوم']));
    teachers.add(Teacher('t2', 'أ. خالد', subjects: ['لغة عربية']));
  }

  void _setupTimes() {
    if (times.isNotEmpty) return;
    var cursor = const TimeOfDay(hour: 7, minute: 15);
    for (var i = 0; i < kLessonCount; i++) {
      final start = cursor;
      final end = _add(start, 45);
      times.add(SlotTime(start, end));
      cursor = _add(end, 5);
    }
  }

  void _setupActivities() {
    if (activities.isNotEmpty) return;
    for (var d = 0; d < kDayCount; d++) {
      activities[ActivitySlot.keyOf(d, kAssemblyKey)] = ActivitySlot(
        day: d, keyName: kAssemblyKey, title: 'الطابور',
        start: const TimeOfDay(hour: 7, minute: 0), end: const TimeOfDay(hour: 7, minute: 15)
      );
      activities[ActivitySlot.keyOf(d, kBreakfastKey)] = ActivitySlot(
        day: d, keyName: kBreakfastKey, title: 'الفطور',
        start: const TimeOfDay(hour: 9, minute: 30), end: const TimeOfDay(hour: 9, minute: 50)
      );
      activities[ActivitySlot.keyOf(d, kPrayerKey)] = ActivitySlot(
        day: d, keyName: kPrayerKey, title: 'الصلاة',
        start: const TimeOfDay(hour: 12, minute: 0), end: const TimeOfDay(hour: 12, minute: 15)
      );
    }
  }

  static TimeOfDay _add(TimeOfDay t, int minutes) {
    final total = t.hour * 60 + t.minute + minutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  String className(String id) => classes.firstWhere((c) => c.id == id, orElse: () => SchoolClass('', '—', '')).name;
  String teacherName(String id) => teachers.firstWhere((t) => t.id == id, orElse: () => Teacher('', '—')).name;
  ActivitySlot activityAt(int day, String keyName) => activities[ActivitySlot.keyOf(day, keyName)]!;
  Lesson? lessonAt(int day, int lessonIndex, String classId) => lessons[Lesson.keyOf(day, lessonIndex, classId)];
  
  Lesson? lessonForTeacher(int day, int lessonIndex, String teacherId) {
    for (final l in lessons.values) {
      if (l.day == day && l.lessonIndex == lessonIndex && l.teacherId == teacherId) return l;
    }
    return null;
  }

  void setLesson(Lesson l) { lessons[l.key] = l; saveData(); notifyListeners(); }
  void removeLesson(int day, int lessonIndex, String classId) { 
    lessons.remove(Lesson.keyOf(day, lessonIndex, classId)); 
    saveData(); notifyListeners(); 
  }

  void setActivity(int day, String keyName, String title, TimeOfDay start, TimeOfDay end) { 
    activities[ActivitySlot.keyOf(day, keyName)]!.title = title; 
    activities[ActivitySlot.keyOf(day, keyName)]!.start = start; 
    activities[ActivitySlot.keyOf(day, keyName)]!.end = end; 
    saveData(); notifyListeners(); 
  }

  void setSlotTime(int index, {TimeOfDay? start, TimeOfDay? end}) {
    if (start != null) times[index].start = start;
    if (end != null) times[index].end = end;
    saveData(); notifyListeners();
  }
  
  void addClass(String name, String level) { 
    classes.add(SchoolClass(DateTime.now().millisecondsSinceEpoch.toString(), name, level)); 
    saveData(); notifyListeners(); 
  }
  void removeClass(String id) { 
    classes.removeWhere((c) => c.id == id); 
    saveData(); notifyListeners(); 
  }
  void updateClass(String id, String name, String level) {
    final c = classes.firstWhere((x) => x.id == id);
    c.name = name; c.level = level; saveData(); notifyListeners();
  }
  
  void addTeacher(String name, List<String> teacherSubjects) { 
    teachers.add(Teacher(DateTime.now().millisecondsSinceEpoch.toString(), name, subjects: teacherSubjects)); 
    saveData(); notifyListeners(); 
  }
  void removeTeacher(String id) { teachers.removeWhere((t) => t.id == id); saveData(); notifyListeners(); }
  
  // إدارة المواد
  void addSubject(String name) {
    subjects.add(Subject(DateTime.now().millisecondsSinceEpoch.toString(), name));
    saveData(); notifyListeners();
  }
  void removeSubject(String id) {
    subjects.removeWhere((s) => s.id == id);
    saveData(); notifyListeners();
  }
  void updateSubject(String id, String name) {
    final s = subjects.firstWhere((x) => x.id == id);
    s.name = name; saveData(); notifyListeners();
  }

  void setSchoolInfo(String name, String year) { schoolName = name; academicYear = year; saveData(); notifyListeners(); }
  
  void setThemeColors(Color primary, Color header, Color subHeader) {
    primaryColor = primary;
    tableHeaderColor = header;
    tableSubHeaderColor = subHeader;
    saveData();
    notifyListeners();
  }

  void setFontSettings(double scale, FontWeight weight) {
    fontScale = scale;
    fontWeight = weight;
    saveData();
    notifyListeners();
  }

  void setAlertSettings(int durationSeconds, bool smartEnabled) {
    alertDurationSeconds = durationSeconds;
    smartNotificationsEnabled = smartEnabled;
    saveData();
    notifyListeners();
  }

  List<SchoolClass> getClassesByLevel(String level) {
    return classes.where((c) => c.level == level).toList();
  }
}
