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

  _Col.day() : type = _ColType.day, lessonIndex = -1, activityKey = '', width = 94;
  _Col.activity(this.activityKey) : type = _ColType.activity, lessonIndex = -1, width = 80;
  _Col.lesson(this.lessonIndex) : type = _ColType.lesson, activityKey = '', width = 134;

  String get topLabel {
    switch (type) {
      case _ColType.day: return 'اليوم';
      case _ColType.activity: return 'نشاط';
      case _ColType.lesson: return '${lessonIndex + 1}';
    }
  }

  String get bottomLabel {
    switch (type) {
      case _ColType.day: return '';
      case _ColType.activity:
        if (activityKey == kAssemblyKey) return 'الطابور';
        if (activityKey == kBreakfastKey) return 'الفطور';
        return 'الصلاة';
      case _ColType.lesson: return AppStore.instance.times[lessonIndex].label;
    }
  }
}

class TimetableScreen extends StatefulWidget {
  final bool teacherMode;
  const TimetableScreen({super.key, required this.teacherMode});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool _isViewingTable = false;
  String? _selectedId;
  String _currentLevel = 'ابتدائي'; 
  Timer? _timer;
  
  // متغيرات التنبيه الذكي
  String? _smartAlertMessage;
  bool _showSmartAlert = true;

  bool get _teacherMode => widget.teacherMode;

  @override
  void initState() {
    super.initState();
    if (_teacherMode) {
      if (AppStore.instance.teachers.isNotEmpty) {
        _selectedId = AppStore.instance.teachers.first.id;
      }
      _isViewingTable = true;
      _setOrientation(true); 
    } else {
      _setOrientation(false); 
    }

    // تحديث التنبيهات كل 30 ثانية
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _isViewingTable) _checkSmartAlerts();
    });
    
    // فحص أولي
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSmartAlerts());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _timer?.cancel();
    super.dispose();
  }

  void _setOrientation(bool landscape) {
    if (landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  // المنطق الذكي لفحص الأنشطة وإظهار التنبيه
  void _checkSmartAlerts() {
    final s = AppStore.instance;
    if (!s.smartNotificationsEnabled || !_isViewingTable || _selectedId == null) {
      if (_smartAlertMessage != null) setState(() => _smartAlertMessage = null);
      return;
    }

    final today = todaySchoolIndex();
    if (today < 0) return;

    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    // فحص ما إذا كنا في وقت نشاط
    String? activeActivity;
    for (var key in [kAssemblyKey, kBreakfastKey, kPrayerKey]) {
      final act = s.activityAt(today, key);
      final startMin = act.start.hour * 60 + act.start.minute;
      final endMin = act.end.hour * 60 + act.end.minute;
      
      if (nowMin >= startMin && nowMin <= endMin) {
        activeActivity = act.title;
        break;
      }
    }

    if (activeActivity != null) {
      // جلب الحصص المتبقية
      final remaining = <Lesson>[];
      for (final l in s.lessons.values) {
        if (l.day != today) continue;
        if (_teacherMode ? l.teacherId != _selectedId : l.classId != _selectedId) continue;
        
        final lessonEnd = s.times[l.lessonIndex].endMinutes;
        if (lessonEnd > nowMin) {
          remaining.add(l);
        }
      }
      remaining.sort((a, b) => a.lessonIndex.compareTo(b.lessonIndex));

      if (remaining.isNotEmpty) {
        final next = remaining.first;
        setState(() {
          _smartAlertMessage = 'أنت الآن في وقت ($activeActivity). متبقي ${remaining.length} حصص اليوم. الحصة القادمة: ${next.subject} (${timeLabel(s.times[next.lessonIndex].start)})';
          _showSmartAlert = true;
        });
        return;
      }
    }

    // إذا لم نكن في نشاط أو لا توجد حصص متبقية
    if (_smartAlertMessage != null) {
      setState(() => _smartAlertMessage = null);
    }
  }

  // --- واجهة اختيار الفصول ---
  Widget _buildClassSelection() {
    final s = AppStore.instance;
    final classes = s.getClassesByLevel(_currentLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جداول الفصول'),
        backgroundColor: s.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: s.primaryColor.withOpacity(0.05),
            child: DropdownButtonFormField<String>(
              value: _currentLevel,
              decoration: const InputDecoration(
                labelText: 'اختر المرحلة الدراسية',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
              items: ['ابتدائي', 'متوسط', 'ثانوي']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _currentLevel = v!),
            ),
          ),
          Expanded(
            child: classes.isEmpty
                ? const Center(child: Text('لا توجد فصول مضافة في هذه المرحلة'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final c = classes[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _selectedId = c.id;
                              _isViewingTable = true;
                              _setOrientation(true);
                              _checkSmartAlerts();
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.grid_view_rounded, size: 40, color: s.primaryColor),
                              const SizedBox(height: 8),
                              Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('اضغط للعرض', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
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

  // --- واجهة الجدول ---
  List<_Col> _columns() {
    final cols = <_Col>[_Col.day(), _Col.activity(kAssemblyKey)];
    for (var i = 0; i < 4; i++) { cols.add(_Col.lesson(i)); }
    cols.add(_Col.activity(kBreakfastKey));
    for (var i = 4; i < 6; i++) { cols.add(_Col.lesson(i)); }
    cols.add(_Col.activity(kPrayerKey));
    for (var i = 6; i < 8; i++) { cols.add(_Col.lesson(i)); }
    return cols;
  }

  Widget _buildTable() {
    if (_selectedId == null) return const Center(child: Text('لم يتم اختيار معلم/فصل'));

    final s = AppStore.instance;
    final cols = _columns();
    final widths = <int, TableColumnWidth>{};
    for (var i = 0; i < cols.length; i++) { widths[i] = FixedColumnWidth(cols[i].width); }

    final rows = <TableRow>[];
    
    // رأس الجدول
    rows.add(TableRow(
      decoration: BoxDecoration(color: s.tableHeaderColor),
      children: cols.map((c) => SizedBox(height: 38, child: Center(child: Text(c.topLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * s.fontScale))))).toList(),
    ));
    rows.add(TableRow(
      decoration: BoxDecoration(color: s.tableSubHeaderColor),
      children: cols.map((c) => SizedBox(height: 38, child: Center(child: Text(c.bottomLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * s.fontScale))))).toList(),
    ));

    // صفوف الأيام
    for (var d = 0; d < kDayCount; d++) {
      rows.add(TableRow(
        children: cols.map((c) {
          switch (c.type) {
            case _ColType.day:
              return Container(
                height: 66, alignment: Alignment.center, 
                color: s.primaryColor.withOpacity(0.1), 
                child: Text(kDayNames[d], style: TextStyle(fontWeight: s.fontWeight, fontSize: 13 * s.fontScale, color: s.primaryColor))
              );
            case _ColType.activity:
              final act = s.activityAt(d, c.activityKey);
              return Container(
                height: 66, alignment: Alignment.center, 
                color: Colors.amber.shade50, 
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(act.title, style: TextStyle(fontSize: 11 * s.fontScale, fontWeight: FontWeight.w600, color: Colors.brown.shade800)),
                    const SizedBox(height: 2),
                    Text(act.timeLabelStr, style: TextStyle(fontSize: 8 * s.fontScale, color: Colors.brown.shade400)),
                  ],
                )
              );
            case _ColType.lesson:
              final l = _teacherMode ? s.lessonForTeacher(d, c.lessonIndex, _selectedId!) : s.lessonAt(d, c.lessonIndex, _selectedId!);
              return Container(
                color: Colors.white, padding: const EdgeInsets.all(3),
                child: LessonBox(
                  lesson: l,
                  subtitle: l == null ? null : (_teacherMode ? s.className(l.classId) : s.teacherName(l.teacherId)),
                  onTap: () async {
                    await showDialog(context: context, builder: (_) => LessonDialog(
                      day: d, lessonIndex: c.lessonIndex, existing: l,
                      fixedClassId: _teacherMode ? null : _selectedId,
                      fixedTeacherId: _teacherMode ? _selectedId : null,
                    ));
                    if (mounted) setState(() {});
                  },
                ),
              );
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

  Widget _buildTimetableView() {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(_teacherMode ? 'جدول المعلم: ${s.teacherName(_selectedId ?? "")}' : 'جدول الفصل: ${s.className(_selectedId ?? "")}'),
        backgroundColor: s.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_teacherMode)
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'العودة لقائمة الفصول',
              onPressed: () {
                setState(() {
                  _isViewingTable = false;
                  _selectedId = null;
                  _smartAlertMessage = null;
                  _setOrientation(false);
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'خروج',
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // شريط التنبيه الذكي أثناء الأنشطة
          if (_smartAlertMessage != null && _showSmartAlert)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade700,
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _smartAlertMessage!,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12 * s.fontScale),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () => setState(() => _showSmartAlert = false),
                  )
                ],
              ),
            ),
          if (_smartAlertMessage == null || !_showSmartAlert)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: s.primaryColor.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in, color: s.primaryColor.withOpacity(0.6), size: 16),
                  const SizedBox(width: 6),
                  Text('استخدم إصبعيك للتكبير والتصغير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10 * s.fontScale, color: s.primaryColor.withOpacity(0.6))),
                ],
              ),
            ),
          
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              minScale: 0.5,
              maxScale: 2.5,
              boundaryMargin: const EdgeInsets.all(50),
              child: Padding(padding: const EdgeInsets.all(10), child: _buildTable()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_teacherMode || _isViewingTable) {
      return _buildTimetableView();
    } else {
      return _buildClassSelection();
    }
  }
}
