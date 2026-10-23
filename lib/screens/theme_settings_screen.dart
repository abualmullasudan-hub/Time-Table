import 'package:flutter/material.dart';
import '../data.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تخصيص المظهر'),
        backgroundColor: s.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: SwitchListTile(
                  title: const Text('الوضع الليلي (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('مريح للعين في الإضاءة المنخفضة'),
                  value: s.isDarkMode,
                  activeColor: s.primaryColor,
                  onChanged: (v) => s.setThemeMode(v),
                  secondary: Icon(s.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: s.primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              const Text('نوع الخط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: ['Tajawal', 'Cairo', 'Almarai', 'Amiri'].map((font) {
                  final isSelected = s.fontFamily == font;
                  return ChoiceChip(
                    label: Text(font, style: TextStyle(fontFamily: font, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : s.primaryColor)),
                    selected: isSelected,
                    selectedColor: s.primaryColor,
                    onSelected: (val) => s.setFontFamily(font),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('لون التطبيق الأساسي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: [
                  Colors.indigo.shade900, Colors.blue.shade800, Colors.teal.shade700, 
                  Colors.green.shade800, Colors.orange.shade800, Colors.red.shade800, 
                  Colors.purple.shade800, Colors.pink.shade700, Colors.brown.shade700
                ].map((color) {
                  final isSelected = s.primaryColor.value == color.value;
                  return GestureDetector(
                    onTap: () => s.setPrimaryColor(color),
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                        boxShadow: [if (isSelected) BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('انحناء الحواف (الزوايا)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Slider(
                value: s.uiRadius,
                min: 0, max: 40, divisions: 8,
                label: s.uiRadius == 0 ? 'مربع' : '${s.uiRadius.toInt()}',
                activeColor: s.primaryColor,
                onChanged: (v) => s.setUiRadius(v),
              ),
              const SizedBox(height: 24),
              const Text('حجم الخط العام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Slider(
                value: s.fontScale,
                min: 0.8, max: 1.4, divisions: 6,
                label: '${(s.fontScale * 100).toInt()}%',
                activeColor: s.primaryColor,
                onChanged: (v) => s.setFontScale(v),
              ),
            ],
          );
        }
      ),
    );
  }
}
