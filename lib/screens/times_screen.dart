import 'package:flutter/material.dart';
import '../data.dart';

class TimesScreen extends StatefulWidget {
  const TimesScreen({super.key});

  @override
  State<TimesScreen> createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  Future<void> _pick(int index, {required bool isStart}) async {
    final s = AppStore.instance;
    final current = isStart ? s.times[index].start : s.times[index].end;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) {
      setState(() {
        s.setSlotTime(index, start: isStart ? picked : null, end: isStart ? null : picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('زمن الحصص'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: kLessonCount,
        itemBuilder: (context, i) {
          final t = s.times[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Text('${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text('الحصة ${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(t.label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => _pick(i, isStart: true),
                    child: Text(timeLabel(t.start)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () => _pick(i, isStart: false),
                    child: Text(timeLabel(t.end)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
