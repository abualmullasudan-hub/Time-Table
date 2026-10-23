import 'package:flutter/material.dart';

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

class SchoolClass {
  final String id;
  String name;
  SchoolClass(this.id, this.name);
}

class Teacher {
  final String id;
  String name;
  Teacher(this.id, this.name);
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

  static String keyOf(int day, int lessonIndex, String classId) =>
      '$day|$lessonIndex|$classId';

  String get key => keyOf(day, lessonIndex, classId);
}

class ActivitySlot {
  final int day;
  final String keyName;
  String title;

  ActivitySlot({required this.day, required this.keyName, required this.title});

  static String keyOf(int day, String keyName) => '$day|$keyName';
  String get id => keyOf(day, keyName);
}

class AppStore extends ChangeNotifier {
  AppStore._() { _seed(); }
  static final AppStore instance = AppStore._();

  final List<SchoolClass> classes = [];
  final List<Teacher> teachers = [];
  final List<SlotTime> times = [];
  final Map<String, Lesson> lessons = {};
  final Map<String, ActivitySlot> activities = {};

  void _seed() {
    const classNames = ['الصف الأول','الصف الثاني','الصف الثالث','الصف الرابع','الصف الخامس'];
    for (var i = 0; i < classNames.length; i++) {
      classes.add(SchoolClass('c${i + 1}', classNames[i]));
    }
    const teacherNames = ['أ. أحمد','أ. محمد','أ. خالد','أ. سعيد','أ. عمر','أ. يوسف','أ. إبراهيم'];
    for (var i = 0; i < teacherNames.length; i++) {
      teachers.add(Teacher('t${i + 1}', teacherNames[i]));
    }
    var cursor = const TimeOfDay(hour: 7, minute: 15);
    for (var i = 0; i < kLessonCount; i++) {
      final start = cursor;
      final end = _add(start, 45);
      times.add(SlotTime(start, end));
      cursor = _add(end, 5);
    }
    for (var d = 0; d < kDayCount; d++) {
      activities[ActivitySlot.keyOf(d, kAssemblyKey)] = ActivitySlot(day: d, keyName: kAssemblyKey, title: 'الطابور');
      activities[ActivitySlot.keyOf(d, kBreakfastKey)] = ActivitySlot(day: d, keyName: kBreakfastKey, title: 'الفطور');
      activities[ActivitySlot.keyOf(d, kPrayerKey)] = ActivitySlot(day: d, keyName: kPrayerKey, title: 'الصلاة');
    }
  }

  static TimeOfDay _add(TimeOfDay t, int minutes) {
    final total = t.hour * 60 + t.minute + minutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  String className(String id) {
    for (final c in classes) { if (c.id == id) return c.name; }
    return '—';
  }

  String teacherName(String id) {
    for (final t in teachers) { if (t.id == id) return t.name; }
    return '—';
  }

  ActivitySlot activityAt(int day, String keyName) => activities[ActivitySlot.keyOf(day, keyName)]!;
  Lesson? lessonAt(int day, int lessonIndex, String classId) => lessons[Lesson.keyOf(day, lessonIndex, classId)];

  Lesson? lessonForTeacher(int day, int lessonIndex, String teacherId) {
    for (final l in lessons.values) {
      if (l.day == day && l.lessonIndex == lessonIndex && l.teacherId == teacherId) return l;
    }
    return null;
  }

  void setLesson(Lesson l) { lessons[l.key] = l; notifyListeners(); }
  void removeLesson(int day, int lessonIndex, String classId) { lessons.remove(Lesson.keyOf(day, lessonIndex, classId)); notifyListeners(); }
  void setActivity(int day, String keyName, String title) { activities[ActivitySlot.keyOf(day, keyName)]!.title = title; notifyListeners(); }
  void setSlotTime(int index, {TimeOfDay? start, TimeOfDay? end}) {
    if (start != null) times[index].start = start;
    if (end != null) times[index].end = end;
    notifyListeners();
  }
  void renameClass(String id, String name) { for (final c in classes) { if (c.id == id) c.name = name; } notifyListeners(); }
  void renameTeacher(String id, String name) { for (final t in teachers) { if (t.id == id) t.name = name; } notifyListeners(); }
  void addTeacher(String name) { teachers.add(Teacher('t${DateTime.now().microsecondsSinceEpoch}', name)); notifyListeners(); }
  void removeTeacher(String id) { teachers.removeWhere((t) => t.id == id); notifyListeners(); }
}
