import 'package:flutter/material.dart';
import '../data.dart';

class LessonDialog extends StatefulWidget {
  final int day;
  final int lessonIndex;
  final Lesson? existing;
  final String? fixedClassId;
  final String? fixedTeacherId;

  const LessonDialog({
    super.key,
    required this.day,
    required this.lessonIndex,
    this.existing,
    this.fixedClassId,
    this.fixedTeacherId,
  });

  @override
  State<LessonDialog> createState() => _LessonDialogState();
}

class _LessonDialogState extends State<LessonDialog> {
  String? _selectedSubject;
  String? _selectedClassId;
  String? _selectedTeacherId;

  @override
  void initState() {
    super.initState();
    final s = AppStore.instance;
    
    // تعبئة البيانات الأولية
    _selectedSubject = widget.existing?.subject;
    if (_selectedSubject == null && s.subjects.isNotEmpty) {
      _selectedSubject = s.subjects.first.name;
    }
    
    _selectedClassId = widget.fixedClassId ?? 
        widget.existing?.classId ?? 
        (s.classes.isNotEmpty ? s.classes.first.id : null);
        
    _selectedTeacherId = widget.fixedTeacherId ?? 
        widget.existing?.teacherId ?? 
        (s.teachers.isNotEmpty ? s.teachers.first.id : null);
  }

  void _save() {
    if (_selectedSubject == null || _selectedClassId == null || _selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال جميع الحقول المطلوبة')),
      );
      return;
    }
    
    final s = AppStore.instance;
    if (widget.existing != null && widget.existing!.classId != _selectedClassId) {
      s.removeLesson(widget.day, widget.lessonIndex, widget.existing!.classId);
    }
    
    s.setLesson(Lesson(
      day: widget.day,
      lessonIndex: widget.lessonIndex,
      classId: _selectedClassId!,
      subject: _selectedSubject!,
      teacherId: _selectedTeacherId!,
    ));
    Navigator.pop(context);
  }

  void _delete() {
    final s = AppStore.instance;
    s.removeLesson(widget.day, widget.lessonIndex,
        widget.existing?.classId ?? widget.fixedClassId!);
    Navigator.pop(context);
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    // جلب قائمة المواد (مع إضافة المادة الحالية إذا لم تكن في القائمة)
    final subjectNames = s.subjects.map((sub) => sub.name).toList();
    if (_selectedSubject != null && !subjectNames.contains(_selectedSubject)) {
      subjectNames.add(_selectedSubject!);
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: s.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit_calendar, color: s.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${kDayNames[widget.day]} - الحصة ${widget.lessonIndex + 1}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(s.times[widget.lessonIndex].label, 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // حقل المادة
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'المادة الدراسية',
                  prefixIcon: Icon(Icons.book),
                ),
                items: subjectNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedSubject = v),
              ),
              const SizedBox(height: 16),
              
              // حقل الفصل
              if (widget.fixedClassId != null)
                _buildInfoRow('الفصل', s.className(widget.fixedClassId!), Icons.groups)
              else
                DropdownButtonFormField<String>(
                  value: _selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'الفصل',
                    prefixIcon: Icon(Icons.groups),
                  ),
                  items: s.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedClassId = v),
                ),
              const SizedBox(height: 16),

              // حقل المعلم
              if (widget.fixedTeacherId != null)
                _buildInfoRow('المعلم', s.teacherName(widget.fixedTeacherId!), Icons.person)
              else
                DropdownButtonFormField<String>(
                  value: _selectedTeacherId,
                  decoration: const InputDecoration(
                    labelText: 'المعلم',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: s.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (v) => setState(() => _selectedTeacherId = v),
                ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      actions: [
        if (widget.existing != null)
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            label: const Text('حذف الحصة', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: s.primaryColor),
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: const Text('حفظ التعديلات'),
        ),
      ],
    );
  }
}
