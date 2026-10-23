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
  String? _selectedId;
  Timer? _timer;
  // تم إزالة كلمة final من هنا لتجنب التحذير
  bool _showBanner = true; 

  bool get _teacherMode => widget.teacherMode;

  @override
  void initState() {
    super.initState();
    
    // إجبار الشاشة على الوضع الأفقي وملء الشاشة
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
    
    // إذا كان معلم، نختار أول معلم افتراضياً. إذا كان فصلاً، نطلب الاختيار.
    if (_teacherMode) {
      if (AppStore.instance.teachers.isNotEmpty) {
        _selectedId = AppStore.instance.teachers.first.id;
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _selectClassDialog());
    }
  }

  @override
  void dispose() {
    // إعادة الشاشة للوضع الطبيعي عند الخروج
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _timer?.cancel();
    super.dispose();
  }

  void _selectClassDialog() {
    final s = AppStore.instance;
    if (s.classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد فصول مضافة. يرجى إضافة فصول من الإعدادات.')));
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? selectedLevel;
        String? selectedClassId;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final classes = selectedLevel == null ? [] : s.classes.where((c) => c.level == selectedLevel).toList();
            
            return AlertDialog(
              title: const Text('اختر المرحلة والفصل'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'المرحلة الدراسية'),
                    items: ['ابتدائي', 'متوسط', 'ثانوي']
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e))) // تم إضافة <String>
                        .toList(),
                    onChanged: (v) => setDialogState(() { selectedLevel = v; selectedClassId = null; }),
                  ),
                  const SizedBox(height: 12),
                  if (selectedLevel != null)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'الفصل'),
                      items: classes
                          .map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))) // تم إضافة <String>
                          .toList(),
                      onChanged: (v) => setDialogState(() => selectedClassId = v),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: const Text('إلغاء')
                ),
                FilledButton(
                  onPressed: selectedClassId == null ? null : () {
                    setState(() => _selectedId = selectedClassId);
                    Navigator.pop(ctx);
                  },
                  child: const Text('عرض الجدول'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
    if (_selectedId == null) return const Center(child: Text('لم يتم اختيار فصل'));

    final cols = _columns();
    final widths = <int, TableColumnWidth>{};
    for (var i = 0; i < cols.length; i++) { widths[i] = FixedColumnWidth(cols[i].width); }

    final rows = <TableRow>[];
    
    // صف العناوين
    rows.add(TableRow(
      decoration: const BoxDecoration(color: Color(0xFFD6E4FF)),
      children: cols.map((c) => SizedBox(height: 38, child: Center(child: Text(c.topLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))))).toList(),
    ));
    rows.add(TableRow(
      decoration: const BoxDecoration(color: Color(0xFFBBDEFB)),
      children: cols.map((c) => SizedBox(height: 38, child: Center(child: Text(c.bottomLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))))).toList(),
    ));

    // صفوف الأيام
    for (var d = 0; d < kDayCount; d++) {
      rows.add(TableRow(
        children: cols.map((c) {
          switch (c.type) {
            case _ColType.day:
              return Container(height: 66, alignment: Alignment.center, color: const Color(0xFFE3F2FD), child: Text(kDayNames[d], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
            case _ColType.activity:
              return Container(height: 66, alignment: Alignment.center, color: const Color(0xFFFFF8E1), child: Text(AppStore.instance.activityAt(d, c.activityKey).title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.brown.shade800)));
            case _ColType.lesson:
              final s = AppStore.instance;
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

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(_teacherMode ? 'جدول المعلم: ${s.teacherName(_selectedId ?? "")}' : 'جدول الفصل: ${s.className(_selectedId ?? "")}'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'خروج',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showBanner)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.amber.shade100,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.zoom_in, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text('استخدم إصبعيك للتكبير والتصغير والتحريك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
}
