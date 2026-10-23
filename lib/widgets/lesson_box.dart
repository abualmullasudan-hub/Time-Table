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
    final l = lesson;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: l == null ? Colors.white : const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: l == null
            ? Icon(Icons.add, size: 18, color: Colors.grey.shade400)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.subject,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.blueGrey.shade600),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
