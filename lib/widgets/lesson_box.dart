import 'package:flutter/material.dart';
import '../data.dart';

class LessonBox extends StatelessWidget {
  final Lesson? lesson;
  final String? subtitle;
  final VoidCallback? onTap;
  final double height;

  const LessonBox({
    super.key,
    required this.lesson,
    this.subtitle,
    this.onTap,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    final l = lesson;
    final isNotEmpty = l != null;

    Color subjectColor = s.primaryColor;
    if (isNotEmpty) {
      final subject = s.subjects.firstWhere(
        (sub) => sub.name == l.subject, 
        orElse: () => Subject('', '', colorValue: s.primaryColor.value)
      );
      subjectColor = subject.color;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(s.uiRadius * 0.5),
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isNotEmpty ? subjectColor.withOpacity(s.isDarkMode ? 0.2 : 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(s.uiRadius * 0.5),
          border: Border.all(
            color: isNotEmpty ? subjectColor.withOpacity(0.4) : (s.isDarkMode ? Colors.white12 : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.subject,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // تم إصلاح الخطأ هنا
                      fontSize: 12 * s.fontScale,
                      color: subjectColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10 * s.fontScale,
                        color: s.isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              )
            : Center(child: Icon(Icons.add, size: 20, color: s.isDarkMode ? Colors.white24 : Colors.grey.shade400)),
      ),
    );
  }
}
