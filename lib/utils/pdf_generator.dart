import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data.dart';

class PdfGenerator {
  static Future<void> exportTimetable({
    required AppStore s,
    required bool isTeacher,
    required String targetId,
  }) async {
    final pdf = pw.Document();
    
    // تحميل خط عربي يدعم الحروف العربية بشكل صحيح في PDF
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    String title = isTeacher ? 'جدول المعلم: ${s.teacherName(targetId)}' : 'جدول الفصل: ${s.className(targetId)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // ورقة أفقية
        textDirection: pw.TextDirection.rtl, // اتجاه من اليمين لليسار
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // الترويسة
              pw.Text(s.schoolName, style: pw.TextStyle(font: fontBold, fontSize: 24)),
              pw.SizedBox(height: 8),
              pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.blue900)),
              pw.Text('العام الدراسي: ${s.academicYear}', style: pw.TextStyle(font: font, fontSize: 14)),
              pw.SizedBox(height: 20),
              
              // الجدول
              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // صف العناوين
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.all(6), child: pw.Text('اليوم', style: pw.TextStyle(font: fontBold))),
                        for (var i = 0; i < kLessonCount; i++)
                          pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.all(6), child: pw.Text('الحصة ${i + 1}', style: pw.TextStyle(font: fontBold))),
                      ],
                    ),
                    // صفوف الأيام
                    for (var d = 0; d < kDayCount; d++)
                      pw.TableRow(
                        children: [
                          pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.all(6), child: pw.Text(kDayNames[d], style: pw.TextStyle(font: fontBold))),
                          for (var i = 0; i < kLessonCount; i++)
                            _buildLessonCell(s, d, i, isTeacher, targetId, font, fontBold),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // فتح نافذة الطباعة أو المشاركة
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'timetable_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildLessonCell(AppStore s, int day, int idx, bool isTeacher, String targetId, pw.Font font, pw.Font fontBold) {
    final l = isTeacher ? s.lessonForTeacher(day, idx, targetId) : s.lessonAt(day, idx, targetId);
    if (l == null) return pw.Container(color: PdfColors.white);
    
    String sub = isTeacher ? s.className(l.classId) : s.teacherName(l.teacherId);
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(l.subject, style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 4),
          pw.Text(sub, style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
        ],
      ),
    );
  }
}
