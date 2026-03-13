import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/notebook.dart';
import '../models/note.dart';
import '../models/pdf_export_mode.dart';
import 'booklet_imposition.dart';
import 'package:image/image.dart' as img;

class PdfService {
  static const PdfColor _accent = PdfColors.blueGrey900;
  static const PdfColor _muted = PdfColors.grey700;
  static const PdfColor _border = PdfColors.grey300;

  static Future<Uint8List> generateNotebookPdf(
    Notebook notebook,
    List<Note> notes, {
    PdfExportMode mode = PdfExportMode.normal,
  }) async {

    final sortedNotes = [...notes];
    sortedNotes.sort((a, b) => a.date.compareTo(b.date));

    if (mode == PdfExportMode.booklet) {
      return _generateBookletPdf(notebook, sortedNotes);
    }

    return _generateNormalPdf(notebook, sortedNotes);
  }
								  

  static Future<Uint8List> _generateNormalPdf(
    Notebook notebook,
    List<Note> notes,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(_buildCoverPage(notebook, notes.length));
			
    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final isLeftPage = i.isEven;
      final pdfImage = await _buildPdfImage(note.imagePath);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(
            top: 28,
            bottom: 32,
            left: isLeftPage ? 48 : 32,
            right: isLeftPage ? 32 : 48,
          ),
          build: (context) {
            return _buildNotePage(
              note: note,
              image: pdfImage,
              pageNumber: context.pageNumber,
              totalPages: context.pagesCount,
              notebookTitle: notebook.title,
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<Uint8List> _generateBookletPdf(
    Notebook notebook,
    List<Note> notes,
  ) async {
    final pdf = pw.Document();

    final totalLogicalPages = 2 + notes.length; // 1 couverture + 1 page blanche + notes
    final imposition = BookletImposition.build(totalLogicalPages);

    final pageBuilders = await _buildLogicalPages(notebook, notes);

    for (final spread in imposition.spreads) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return _buildBookletSpread(
              leftPage: _buildLogicalPageWidget(
                logicalPageNumber: spread.leftPage,
                pageBuilders: pageBuilders,
              ),
              rightPage: _buildLogicalPageWidget(
                logicalPageNumber: spread.rightPage,
                pageBuilders: pageBuilders,
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<List<pw.Widget Function()>> _buildLogicalPages(
    Notebook notebook,
    List<Note> notes,
  ) async {
    final pages = <pw.Widget Function()>[];

    // Page 1 : couverture
    pages.add(() => _buildBookletCoverPageContent(notebook, notes.length));

    // Page 2 : verso de couverture volontairement blanc
    pages.add(() => pw.SizedBox());

    // Page 3+ : notes
    int actualPageNumber = 1;
    for (final note in notes) {
      final pdfImage = await _buildPdfImage(note.imagePath);
      final currentPageNumber = actualPageNumber;

      pages.add(
        () => _buildBookletNotePageContent(
          note: note,
          image: pdfImage,
          notebookTitle: notebook.title,
          pageNumber: currentPageNumber,
          totalPages: notes.length
        ),
      );
      actualPageNumber += 1;

    }

    return pages;
  }

  static pw.Widget _buildLogicalPageWidget({
    required int? logicalPageNumber,
    required List<pw.Widget Function()> pageBuilders,
  }) {
    if (logicalPageNumber == null) {
      return _buildBookletPaperPage(
        child: pw.SizedBox(),
      );
    }

    final index = logicalPageNumber - 1;

    if (index < 0 || index >= pageBuilders.length) {
      return _buildBookletPaperPage(
        child: pw.SizedBox(),
      );
    }

    return _buildBookletPaperPage(
      child: pageBuilders[index](),
    );
  }

  static pw.Widget _buildBookletSpread({
    required pw.Widget leftPage,
    required pw.Widget rightPage,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(child: leftPage),
        pw.SizedBox(width: 12),
        pw.Expanded(child: rightPage),
      ],
    );
  }

  static pw.Widget _buildBookletPaperPage({
    required pw.Widget child,
  }) {
    return pw.Container(
      height: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border),
        color: PdfColors.white,
      ),
      padding: const pw.EdgeInsets.all(18),
      child: child,
    );
  }

  static pw.Page _buildCoverPage(Notebook notebook, int noteCount) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return _buildCoverContent(
          notebook: notebook,
          noteCount: noteCount,
        );
      },
    );
  }

  static pw.Widget _buildBookletCoverPageContent(
    Notebook notebook,
    int noteCount,
  ) {
    return _buildCoverContent(
      notebook: notebook,
      noteCount: noteCount,
    );
  }

  static pw.Widget _buildCoverContent({
    required Notebook notebook,
    required int noteCount,
  }) {
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _accent, width: 2),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(28),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Spacer(),
            pw.Text(
              notebook.title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: _accent,
              ),
            ),
            pw.SizedBox(height: 12),
            if (notebook.subtitle.trim().isNotEmpty)
              pw.Text(
                notebook.subtitle,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 16,
                  color: _muted,
                ),
              ),
            pw.SizedBox(height: 24),
            pw.Container(
              width: 60,
              height: 2,
              color: _accent,
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              notebook.year.toString(),
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '$noteCount note${noteCount > 1 ? 's' : ''}',
              style: pw.TextStyle(
                fontSize: 12,
                color: _muted,
              ),
            ),
            pw.Spacer(),
          ],
        ),
      ),
    );
		
	  
  }

  static pw.Widget _buildNotePage({
    required Note note,
    required pw.MemoryImage? image,
    required int pageNumber,
    required int totalPages,
    required String notebookTitle,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(notebookTitle),
        pw.SizedBox(height: 18),

        pw.Text(
          note.title,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: _accent,
          ),
        ),
        pw.SizedBox(height: 6),

        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _border),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            note.date,
            style: pw.TextStyle(
              fontSize: 11,
              color: _muted,
            ),
          ),
        ),

        pw.SizedBox(height: 18),

        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (image != null) ...[
                _buildImageBox(image, height: 280),
                pw.SizedBox(height: 20),
              ],
              pw.SizedBox(
                width: double.infinity,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  child: pw.Text(
                    note.caption.trim().isEmpty ? '' : note.caption,
                    textAlign: pw.TextAlign.justify,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      lineSpacing: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _buildFooter(pageNumber, totalPages),
      ],
    );
  }

  static pw.Widget _buildBookletNotePageContent({
    required Note note,
    required pw.MemoryImage? image,
    required String notebookTitle,
    required int pageNumber,
    required int totalPages,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(notebookTitle),
        pw.SizedBox(height: 12),
        pw.Text(
          note.title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: _accent,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _border),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            note.date,
            style: pw.TextStyle(
              fontSize: 9,
              color: _muted,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if(image != null)...[
                _buildImageBox(image, height: 170),
                pw.SizedBox(height: 12),
              ],
              pw.Expanded(
                child: pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    note.caption.trim().isEmpty ? '' : note.caption,
                    textAlign: pw.TextAlign.justify,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      lineSpacing: 3,
                    ),
                    maxLines: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        _buildFooter(pageNumber, totalPages),
      ],
    );
  }

  static pw.Widget _buildImageBox(pw.MemoryImage? image, {required double height}) {
    return pw.Container(
      width: double.infinity,
      height: height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border),
        color: PdfColors.grey100,
      ),
      child: image != null
          ? pw.Center(
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain,
              ),
            )
          : pw.Center(
              child: pw.Text(
                'No image',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ),

								
											 
		
    );
  }

  static pw.Widget _buildHeader(String notebookTitle) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          notebookTitle,
          style: pw.TextStyle(
            fontSize: 10,
            color: _muted,
          ),
        ),
        pw.Container(
          width: 80,
          height: 1,
          color: _border,
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(int pageNumber, int totalPages) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(
          width: 80,
          height: 1,
          color: _border,
        ),
        pw.Text(
          'Page $pageNumber / $totalPages',
          style: pw.TextStyle(
            fontSize: 10,
            color: _muted,
          ),
        ),
      ],
    );
  }

  static Future<pw.MemoryImage?> _loadMemoryImage(String? imagePath) async {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }

    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      return null;
    }

    final bytes = await imageFile.readAsBytes();
    return pw.MemoryImage(bytes);
  }

  static Future<pw.MemoryImage?> _buildPdfImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    final file = File(imagePath);
    if (!file.existsSync()) return null;

    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return pw.MemoryImage(bytes);
    }

    img.Image finalImage = decoded;

    // Si l’image est en portrait, on la tourne de -90°
    if (decoded.height > decoded.width) {
      finalImage = img.copyRotate(decoded, angle: -90);
    }

    final outputBytes = img.encodeJpg(finalImage, quality: 95);
    return pw.MemoryImage(outputBytes);
  }
}

