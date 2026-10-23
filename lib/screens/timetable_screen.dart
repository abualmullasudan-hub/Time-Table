import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../data.dart';
import '../widgets/lesson_box.dart';
import '../widgets/lesson_dialog.dart';

enum _ColType { day, activity, lesson }

class _Col {
  final _ColType type;
  final int lessonIndex;
  final String activityKey;
  final double width;

  _Col.day()
      : type = _ColType.day,
        lessonIndex = -1,
        activityKey = '',
        width = 94;

  _Col.activity(this.activityKey)
      : type = _ColType.activity,
        lessonIndex = -1,
        width = 80;

  _Col.lesson(this.lessonIndex)
      : type = _ColType.lesson,
        activityKey = '',
        width = 134;

  String get topLabel {
    switch (type) {
      case _ColType.day:
        return 'اليوم';
      case _ColType.activity:
        return 'نشاط';
      case _ColType.lesson:
        return '${lessonIndex + 1}';
    }
  }

  String get bottomLabel {
    switch (type) {
      case _ColType.day:
        return '';
      case _ColType.activity:
        if (activityKey == kAssemblyKey) return 'الطابور';
        if (activityKey == kBreakfastKey) return 'الفطور';
        return 'الصلاة';
      case _ColType.lesson:
        return AppStore.instance.times[lessonIndex].label;
    }
  }
}

class _BannerInfo {
  final Lesson lesson;
  final bool isNow;
  _BannerInfo(this.lesson, this.isNow);
}

class TimetableScreen extends StatefulWidget {
  final bool teacherMode;
  const TimetableScreen({super.key, required this.teacherMode});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late String _selectedId;
  Timer? _timer;
  bool _showBanner = true;
  bool _isLandscape = true;

  bool get _teacherMode => widget.teacherMode;

  @override
  void initState() {
    super.initState();
    final s = AppStore.instance;
    _selectedId = _teacherMode ? s.teachers.first.id : s.classes.first.id;
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _timer?.cancel();
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  Lesson? _lessonAt(int day, int idx) {
    final s = AppStore.instance;
    return _teacherMode
        ? s.lessonForTeacher(day, idx, _selectedId)
        : s.lessonAt(day, idx, _selectedId);
  }

  _BannerInfo? _currentOrNext() {
    final s = AppStore.instance;
    final d = todaySchoolIndex();
    if (d < 0) return null;

    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    final list = <Lesson>[];
    for (final l in s.lessons.values) {
      if (l.day != d) continue;
      if (_teacherMode ? l.teacherId != _selectedId : l.classId != _selectedId) {
        continue;
      }
      list.add(l);
    }
    if (list.isEmpty) return null;
    list.sort((a, b) => a.lessonIndex.compareTo(b.lessonIndex));

    for (final l in list) {
      final t = s.times[l.lessonIndex];
      if (nowMin >= t.startMinutes - 10 && nowMin <= t.endMinutes) {
        return _BannerInfo(l, nowMin >= t.startMinutes);
      }
    }
    for (final l in list) {
      final t = s.times[l.lessonIndex];
      if (nowMin < t.startMinutes) return _BannerInfo(l, false);
    }
    return null;
  }

  List<_Col> _columns() {
    final cols = <_Col>[_Col.day(), _Col.activity(kAssemblyKey)];
    for (var i = 0; i < 4; i++) {
      cols.add(_Col.lesson(i));
    }
    cols.add(_Col.activity(kBreakfastKey));
    for (var i = 4; i < 6; i++) {
      cols.add(_Col.lesson(i));
    }
    cols.add(_Col.activity(kPrayerKey));
    for (var i = 6; i < 8; i++) {
      cols.add(_Col.lesson(i));
    }
    return cols;
  }

  Widget _headerCell(String text) => SizedBox(
        height: 38,
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      );

  Widget _dayCell(int day) => Container(
        height: 66,
        alignment: Alignment.center,
        color: const Color(0xFFE3F2FD),
        child: Text(kDayNames[day],
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );

  Widget _activityCell(int day, String key) => Container(
        height: 66,
        alignment: Alignment.center,
        color: const Color(0xFFFFF8E1),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          AppStore.instance.activityAt(day, key).title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade800),
        ),
      );

  Widget _lessonCell(int day, int idx) {
    final s = AppStore.instance;
    final l = _lessonAt(day, idx);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(3),
      child: LessonBox(
        lesson: l,
        subtitle: l == null
            ? null
            : (_teacherMode ? s.className(l.classId) : s.teacherName(l.teacherId)),
        onTap: () => _openDialog(day, idx, l),
      ),
    );
  }

  Future<void> _openDialog(int day, int idx, Lesson? existing) async {
    await showDialog(
      context: context,
      builder: (_) => LessonDialog(
        day: day,
        lessonIndex: idx,
        existing: existing,
        fixedClassId: _teacherMode ? null : _selectedId,
        fixedTeacherId: _teacherMode ? _selectedId : null,
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _buildTable() {
    final cols = _columns();
    final widths = <int, TableColumnWidth>{};
    for (var i = 0; i < cols.length; i++) {
      widths[i] = FixedColumnWidth(cols[i].width);
    }

    final rows = <TableRow>[];

    rows.add(TableRow(
      decoration: const BoxDecoration(color: Color(0xFFD6E4FF)),
      children: cols.map((c) => _headerCell(c.topLabel)).toList(),
    ));
    rows.add(TableRow(
      decoration: const BoxDecoration(color: Color(0xFFBBDEFB)),
      children: cols.map((c) => _headerCell(c.bottomLabel)).toList(),
    ));

    for (var d = 0; d < kDayCount; d++) {
      rows.add(TableRow(
        children: cols.map((c) {
          switch (c.type) {
            case _ColType.day:
              return _dayCell(d);
            case _ColType.activity:
              return _activityCell(d, c.activityKey);
            case _ColType.lesson:
              return _lessonCell(d, c.lessonIndex);
          }
        }).toList(),
      ));
    }

    return Table(
      border: TableBorder.all(color: Colors.blueGrey.shade100, width: 1),
      columnWidths: widths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  Widget _selector() {
    final s = AppStore.instance;
    final items = _teacherMode ? s.teachers : s.classes;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: DropdownButtonFormField<String>(
        value: _selectedId,
        isDense: true,
        decoration: InputDecoration(
          labelText: _teacherMode ? 'اختر المعلم' : 'اختر الفصل',
          prefixIcon: Icon(_teacherMode ? Icons.person : Icons.groups),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items
            .map((e) => DropdownMenuItem(
                value: e.id,
                child: Text(e is Teacher ? e.name : (e as SchoolClass).name)))
            .toList(),
        onChanged: (v) => setState(() => _selectedId = v!),
      ),
    );
  }

  Widget _banner() {
    if (!_showBanner) return const SizedBox.shrink();
    final info = _currentOrNext();
    if (info == null) return const SizedBox.shrink();

    final s = AppStore.instance;
    final l = info.lesson;
    final t = s.times[l.lessonIndex];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${info.isNow ? "الحصة الحالية" : "الحصة القادمة"} • الحصة ${l.lessonIndex + 1} • ${t.label}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  l.subject,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18),
                ),
                Text(
                  _teacherMode
                      ? s.className(l.classId)
                      : s.teacherName(l.teacherId),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showBanner = false),
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_teacherMode ? 'جدول المعلم' : 'جدول الفصل'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isLandscape ? Icons.stay_current_portrait : Icons.stay_current_landscape),
            onPressed: _toggleOrientation,
            tooltip: 'تدوير الشاشة',
          ),
        ],
      ),
      body: Column(
        children: [
          _selector(),
          _banner(),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildTable(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
