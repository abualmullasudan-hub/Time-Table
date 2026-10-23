import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../data.dart';
import '../widgets/lesson_box.dart';
import '../widgets/lesson_dialog.dart';
import '../utils/pdf_generator.dart';

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

  bool get _teacherMode => widget.teacherMode;

  @override
  void initState() {
    super.initState();
    if (_teacherMode) {
      if (AppStore.instance.teachers.isNotEmpty) _selectedId = AppStore.instance.teachers.first.id;
      _isViewingTable = true;
      _setOrientation(true); 
    } else {
      _setOrientation(false); 
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _timer?.cancel();
    super.dispose();
  }

  void _setOrientation(bool landscape) {
    if (landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  Widget _buildClassSelection() {
    final s = AppStore.instance;
    final classes = s.getClassesByLevel(_currentLevel);

    return Scaffold(
      appBar: AppBar(title: const Text('جداول الفصول'), backgroundColor: s.primaryColor, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: s.primaryColor.withOpacity(0.05),
            child: DropdownButtonFormField<String>(
              value: _currentLevel,
              decoration: InputDecoration(
                labelText: 'المرحلة الدراسية', 
                filled: true, 
                fillColor: s.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white
              ),
              items: ['ابتدائي', 'متوسط', 'ثانوي'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _currentLevel = v!),
            ),
          ),
          Expanded(
            child: classes.isEmpty
                ? const Center(child: Text('لا توجد فصول'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12, 
                      childAspectRatio: 1.3
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final c = classes[index];
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(s.uiRadius),
                          onTap: () { 
                            setState(() { 
                              _selectedId = c.id; 
                              _isViewingTable = true; 
                              _setOrientation(true); 
                            }); 
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.grid_view_rounded, size: 40, color: s.primaryColor),
                              const SizedBox(height: 8),
                              Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildTable() {
    if (_selectedId == null) return const Center(child: Text('اختر معلم/فصل'));
    final s = AppStore.instance;
    
    return Table(
      border: TableBorder.all(color: s.isDarkMode ? Colors.white12 : Colors.blueGrey.shade100, width: 1),
      columnWidths: const {
        0: FixedColumnWidth(90), 
        1: FixedColumnWidth(70), 
        2: FixedColumnWidth(130), 
        3: FixedColumnWidth(130), 
        4: FixedColumnWidth(130), 
        5: FixedColumnWidth(130), 
        6: FixedColumnWidth(70), 
        7: FixedColumnWidth(130), 
        8: FixedColumnWidth(130), 
        9: FixedColumnWidth(70), 
        10: FixedColumnWidth(130), 
        11: FixedColumnWidth(130)
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // الصف الأول: العناوين
        TableRow(
          decoration: BoxDecoration(color: s.primaryColor.withOpacity(0.1)),
          children: ['اليوم', 'نشاط', '1', '2', '3', '4', 'نشاط', '5', '6', 'نشاط', '7', '8']
              .map((t) => SizedBox(height: 38, child: Center(child: Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: s.primaryColor)))))
              .toList(),
        ),
        
        // الصف الثاني: أوقات الحصص (تم إصلاح الخطأ هنا ليكون 12 عموداً بالضبط)
        TableRow(
          decoration: BoxDecoration(color: s.primaryColor.withOpacity(0.05)),
          children: [
            const SizedBox(height: 38), // 1
            const SizedBox(height: 38), // 2
            ...s.times.sublist(0, 4).map((t) => SizedBox(height: 38, child: Center(child: Text(t.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))))), // 3,4,5,6
            const SizedBox(height: 38), // 7
            ...s.times.sublist(4, 6).map((t) => SizedBox(height: 38, child: Center(child: Text(t.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))))), // 8,9
            const SizedBox(height: 38), // 10
            ...s.times.sublist(6, 8).map((t) => SizedBox(height: 38, child: Center(child: Text(t.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))))), // 11,12
          ],
        ),
        
        // صفوف الأيام
        ...List.generate(kDayCount, (d) {
          return TableRow(
            children: [
              Container(height: 66, alignment: Alignment.center, color: s.primaryColor.withOpacity(0.05), child: Text(kDayNames[d], style: TextStyle(fontWeight: FontWeight.bold, color: s.primaryColor))),
              _buildAct(d, kAssemblyKey),
              _buildLesson(d, 0), _buildLesson(d, 1), _buildLesson(d, 2), _buildLesson(d, 3),
              _buildAct(d, kBreakfastKey),
              _buildLesson(d, 4), _buildLesson(d, 5),
              _buildAct(d, kPrayerKey),
              _buildLesson(d, 6), _buildLesson(d, 7),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildAct(int day, String key) {
    final act = AppStore.instance.activityAt(day, key);
    return Container(
      height: 66, alignment: Alignment.center, color: Colors.orange.withOpacity(0.1), 
      child: Text(act.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade800))
    );
  }

  Widget _buildLesson(int day, int idx) {
    final s = AppStore.instance;
    final l = _teacherMode ? s.lessonForTeacher(day, idx, _selectedId!) : s.lessonAt(day, idx, _selectedId!);
    return Container(
      color: s.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, 
      padding: const EdgeInsets.all(3),
      child: LessonBox(
        lesson: l,
        subtitle: l == null ? null : (_teacherMode ? s.className(l.classId) : s.teacherName(l.teacherId)),
        onTap: () async {
          await showDialog(
            context: context, 
            builder: (_) => LessonDialog(
              day: day, 
              lessonIndex: idx, 
              existing: l, 
              fixedClassId: _teacherMode ? null : _selectedId, 
              fixedTeacherId: _teacherMode ? _selectedId : null
            )
          );
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    if (!_isViewingTable) return _buildClassSelection();

    return Scaffold(
      appBar: AppBar(
        title: Text(_teacherMode ? 'جدول المعلم: ${s.teacherName(_selectedId ?? "")}' : 'جدول الفصل: ${s.className(_selectedId ?? "")}'),
        backgroundColor: s.primaryColor, 
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير كملف PDF',
            onPressed: () {
              if (_selectedId != null) {
                PdfGenerator.exportTimetable(s: s, isTeacher: _teacherMode, targetId: _selectedId!);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.close), 
            onPressed: () {
              if (_teacherMode) {
                Navigator.pop(context);
              } else {
                setState(() { _isViewingTable = false; _selectedId = null; _setOrientation(false); });
              }
            }
          ),
        ],
      ),
      body: InteractiveViewer(
        constrained: false, 
        minScale: 0.5, 
        maxScale: 2.5, 
        boundaryMargin: const EdgeInsets.all(50),
        child: Padding(padding: const EdgeInsets.all(10), child: _buildTable()),
      ),
    );
  }
}
