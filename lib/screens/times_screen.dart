import 'package:flutter/material.dart';
import '../data.dart';

class TimesScreen extends StatefulWidget {
  const TimesScreen({super.key});

  @override
  State<TimesScreen> createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  int _selectedDay = 0;

  Future<void> _pickTime({
    required TimeOfDay initialTime,
    required Function(TimeOfDay) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الأوقات'),
          backgroundColor: s.primaryColor,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'أوقات الحصص', icon: Icon(Icons.schedule)),
              Tab(text: 'أوقات الأنشطة', icon: Icon(Icons.free_breakfast)),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: s,
          builder: (context, _) {
            return TabBarView(
              children: [
                // 1. تبويب أوقات الحصص
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kLessonCount,
                  itemBuilder: (context, i) {
                    final t = s.times[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: s.primaryColor.withOpacity(0.1),
                          child: Text('${i + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: s.primaryColor)),
                        ),
                        title: Text('الحصة ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(t.label),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius * 0.5)),
                              ),
                              onPressed: () => _pickTime(
                                initialTime: t.start,
                                onPicked: (p) => s.setSlotTime(i, start: p),
                              ),
                              child: Text(timeLabel(t.start)),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius * 0.5)),
                              ),
                              onPressed: () => _pickTime(
                                initialTime: t.end,
                                onPicked: (p) => s.setSlotTime(i, end: p),
                              ),
                              child: Text(timeLabel(t.end)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 2. تبويب أوقات الأنشطة
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: s.primaryColor.withOpacity(0.05),
                        border: Border(bottom: BorderSide(color: s.isDarkMode ? Colors.white12 : Colors.grey.shade200)),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedDay,
                        decoration: InputDecoration(
                          labelText: 'اختر اليوم لتعديل أوقاته',
                          filled: true,
                          fillColor: s.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                          isDense: true,
                        ),
                        items: List.generate(kDayCount, (index) {
                          return DropdownMenuItem(
                            value: index,
                            child: Text(kDayNames[index]),
                          );
                        }),
                        onChanged: (v) => setState(() => _selectedDay = v!),
                      ),
                    ),
                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildActivityTile(s, kAssemblyKey, 'الطابور', Icons.flag),
                          _buildActivityTile(s, kBreakfastKey, 'الفطور', Icons.coffee),
                          _buildActivityTile(s, kPrayerKey, 'الصلاة', Icons.mosque),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityTile(AppStore s, String key, String defaultTitle, IconData icon) {
    final act = s.activityAt(_selectedDay, key);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: s.primaryColor, size: 28),
        title: Text(defaultTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(act.timeLabelStr),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius * 0.5)),
              ),
              onPressed: () => _pickTime(
                initialTime: act.start,
                onPicked: (p) => s.setActivity(_selectedDay, key, act.title, p, act.end),
              ),
              child: Text(timeLabel(act.start)),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius * 0.5)),
              ),
              onPressed: () => _pickTime(
                initialTime: act.end,
                onPicked: (p) => s.setActivity(_selectedDay, key, act.title, act.start, p),
              ),
              child: Text(timeLabel(act.end)),
            ),
          ],
        ),
      ),
    );
  }
}
