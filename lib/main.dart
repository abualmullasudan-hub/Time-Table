import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'data.dart';

void main() => runApp(const SchoolScheduleApp());

class SchoolScheduleApp extends StatelessWidget {
  const SchoolScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStore.instance;
    
    // تم حذف الشرطة السفلية من اسم الدالة هنا
    TextTheme getTextTheme() {
      switch (s.fontFamily) {
        case 'Cairo': return GoogleFonts.cairoTextTheme();
        case 'Almarai': return GoogleFonts.almaraiTextTheme();
        case 'Amiri': return GoogleFonts.amiriTextTheme();
        default: return GoogleFonts.tajawalTextTheme();
      }
    }

    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'جدول الحصص',
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          theme: ThemeData(
            useMaterial3: true,
            brightness: s.isDarkMode ? Brightness.dark : Brightness.light,
            textTheme: getTextTheme(), // تم التعديل هنا
            colorScheme: ColorScheme.fromSeed(
              seedColor: s.primaryColor,
              primary: s.primaryColor,
              brightness: s.isDarkMode ? Brightness.dark : Brightness.light,
              // تم حذف background واستخدام surface
              surface: s.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, 
            ),
            scaffoldBackgroundColor: s.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: s.isDarkMode ? Colors.white : s.primaryColor,
              titleTextStyle: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: s.isDarkMode ? Colors.white : s.primaryColor, 
                fontFamily: GoogleFonts.getFont(s.fontFamily).fontFamily
              ),
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(s.uiRadius),
                side: BorderSide(color: s.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0), width: 1.5),
              ),
              color: s.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: s.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(s.uiRadius), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(s.uiRadius), borderSide: BorderSide(color: s.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0), width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(s.uiRadius), borderSide: BorderSide(color: s.primaryColor, width: 2)),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.uiRadius)),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  fontFamily: GoogleFonts.getFont(s.fontFamily).fontFamily
                ),
              ),
            ),
          ),
          home: const HomeScreen(),
        );
      }
    );
  }
}
