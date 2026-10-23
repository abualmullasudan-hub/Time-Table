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
  late final TextEditingController _subject;
  String? _classId;
  String? _teacherId;

  @override
  void initState() {
    super.initState();
    final s = AppStore.instance;
    _subject = TextEditingController(text: widget.existing?.subject ?? '');
    _classId = widget.fixedClassId ??
        widget.existing?.classId ??
        (s.classes.isNotEmpty ? s.classes.first.id : null);
    _teacherId = widget.fixedTeacherId ??
        widget.existing?.teacherId ??
        (s.teachers.isNotEmpty ? s.teachers.first.id : null);
  }

  @override
  void dispose() {
    _subject.dispose();
    super.dispose();
  }

  void _save() {
    final subject = _subject.text.trim();
    if (subject.isEmpty || _classId == null || _teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إكمال اسم المادة والفصل والأستاذ')),
      );
      return;
    }
    final s = AppStore.instance;
    if (widget.existing != null && widget.existing!.classId != _classId) {
      s.removeLesson(widget.day, widget.lessonIndex, widget.existing!.classId);
    }
    s.setLesson(Lesson(
      day: widget.day,
      lessonIndex: widget.lessonIndex,
      classId: _classId!,
      subject: subject,
      teacherId: _teacherId!,
    ));
    Navigator.pop(context);
  }

  void _delete() {
    final s = AppStore.instance;
    s.removeLesson(widget.day, widget.lessonIndex,
        widget.existing?.classId ?? widget.fixedClassId!);
    Navigator.pop(context);
  }

  Widget _fixedBox(String label, String value) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return AlertDialog(
      title: Text('${kDayNames[widget.day]} • الحصة ${widget.lessonIndex + 1}'),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _subject,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'اسم المادة',
                  hintText: 'اكتب اسم المادة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              if (widget.fixedClassId != null)
                _fixedBox('الفصل', s.className(widget.fixedClassId!))
              else
                DropdownButtonFormField<String>(
                  value: _classId,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'الفصل',
                    border: OutlineInputBorder(),
                  ),
                  items: s.classes
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _classId = v),
                ),
              const SizedBox(height: 14),
              if (widget.fixedTeacherId != null)
                _fixedBox('الأستاذ', s.teacherName(widget.fixedTeacherId!))
              else
                DropdownButtonFormField<String>(
                  value: _teacherId,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'الأستاذ',
                    border: OutlineInputBorder(),
                  ),
                  items: s.teachers
                      .map((t) =>
                          DropdownMenuItem(value: t.id, child: Text(t.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _teacherId = v),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.existing != null)
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            label: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _save, child: const Text('حفظ')),
      ],
    );
  }
}
