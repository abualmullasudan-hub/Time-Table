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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // خلفية ملونة بشفافية إذا كانت الحصة موجودة، أو رمادية فاتحة إذا كانت فارغة
          color: isNotEmpty ? s.primaryColor.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isNotEmpty ? s.primaryColor.withOpacity(0.3) : Colors.grey.shade200,
            width: 1,
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
                      // تطبيق إعدادات الخطوط من الثيم
                      fontWeight: s.fontWeight == FontWeight.bold ? FontWeight.bold : FontWeight.w700,
                      fontSize: 13 * s.fontScale,
                      color: s.primaryColor,
                      height: 1.2,
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
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              )
            : Center(
                child: Icon(Icons.add, size: 20, color: Colors.grey.shade400),
              ),
      ),
    );
  }
}
