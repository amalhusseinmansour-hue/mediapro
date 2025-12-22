import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';

/// خدمة تصدير التقارير كـ PDF
class PDFExportService {
  /// تصدير تقرير المنشورات
  Future<File> exportPostsReport({
    required List<PostModel> posts,
    required Map<String, dynamic> stats,
    String title = 'تقرير المنشورات',
  }) async {
    final pdf = pw.Document();

    // إضافة الصفحات
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          // Header
          _buildHeader(title),
          pw.SizedBox(height: 20),

          // Statistics
          _buildStatsSection(stats),
          pw.SizedBox(height: 20),

          // Posts Table
          _buildPostsTable(posts),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return await _savePDF(pdf, 'posts_report');
  }

  /// تصدير تقرير التحليلات
  Future<File> exportAnalyticsReport({
    required Map<String, dynamic> analytics,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          // Header
          _buildHeader('تقرير التحليلات'),
          pw.SizedBox(height: 10),

          // Date Range
          pw.Text(
            'من ${_formatDate(startDate)} إلى ${_formatDate(endDate)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 20),

          // Analytics Data
          _buildAnalyticsSection(analytics),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return await _savePDF(pdf, 'analytics_report');
  }

  /// بناء Header
  pw.Widget _buildHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColor.fromInt(0xFF00D9FF), PdfColor.fromInt(0xFF9D4EDD)],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Social Media Manager Pro',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey300,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'تاريخ التقرير: ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey300,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// بناء قسم الإحصائيات
  pw.Widget _buildStatsSection(Map<String, dynamic> stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'الإحصائيات العامة',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('إجمالي المنشورات', stats['totalPosts']?.toString() ?? '0'),
              _buildStatItem('المنشورة', stats['publishedPosts']?.toString() ?? '0'),
              _buildStatItem('المجدولة', stats['scheduledPosts']?.toString() ?? '0'),
              _buildStatItem('إجمالي التفاعل', stats['totalEngagement']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء عنصر إحصائية
  pw.Widget _buildStatItem(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF00D9FF),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// بناء جدول المنشورات
  pw.Widget _buildPostsTable(List<PostModel> posts) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'تفاصيل المنشورات',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header Row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('التاريخ', isHeader: true),
                _buildTableCell('المحتوى', isHeader: true),
                _buildTableCell('المنصات', isHeader: true),
                _buildTableCell('الحالة', isHeader: true),
                _buildTableCell('التفاعل', isHeader: true),
              ],
            ),
            // Data Rows
            ...posts.take(20).map((post) {
              final engagement = post.analytics?['likes'] ?? 0;
              return pw.TableRow(
                children: [
                  _buildTableCell(_formatDate(post.createdAt)),
                  _buildTableCell(_truncate(post.content, 30)),
                  _buildTableCell(post.platforms.join(', ')),
                  _buildTableCell(_getStatusText(post.status)),
                  _buildTableCell(engagement.toString()),
                ],
              );
            }).toList(),
          ],
        ),
        if (posts.length > 20)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'وعرض ${posts.length - 20} منشور إضافي...',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
      ],
    );
  }

  /// بناء خلية جدول
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// بناء قسم التحليلات
  pw.Widget _buildAnalyticsSection(Map<String, dynamic> analytics) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'التحليلات التفصيلية',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 12),
          ...analytics.entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    entry.key,
                    style: const pw.TextStyle(fontSize: 12),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    entry.value.toString(),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF00D9FF),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// بناء Footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            'صفحة ${context.pageNumber} من ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'تم الإنشاء بواسطة Social Media Manager Pro',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// حفظ PDF
  Future<File> _savePDF(pw.Document pdf, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// مشاركة PDF
  Future<void> sharePDF(File pdfFile, String title) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: title,
        text: 'تقرير من Social Media Manager Pro',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل مشاركة التقرير: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// طباعة PDF
  Future<void> printPDF(pw.Document pdf) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل طباعة التقرير: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// معاينة PDF
  Future<void> previewPDF(pw.Document pdf, String title) async {
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '$title.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل معاينة التقرير: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Helpers
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _truncate(String text, int length) {
    return text.length > length ? '${text.substring(0, length)}...' : text;
  }

  String _getStatusText(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return 'مسودة';
      case PostStatus.scheduled:
        return 'مجدولة';
      case PostStatus.published:
        return 'منشورة';
      case PostStatus.failed:
        return 'فشل';
    }
  }
}
