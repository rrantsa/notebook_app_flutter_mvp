import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/notebook.dart';
import '../models/note.dart';

class PdfService {
  static const PdfColor _accent = PdfColors.blueGrey900;
  static const PdfColor _muted = PdfColors.grey700;
  static const PdfColor _border = PdfColors.grey300;

  static Future<Uint8List> generateNotebookPdf(
    Notebook notebook,
    List<Note> notes,
  ) async {
    final pdf = pw.Document();

    final sortedNotes = [...notes];
    sortedNotes.sort((a, b) => a.date.compareTo(b.date));

    pdf.addPage(_buildCoverPage(notebook, sortedNotes.length));

    for (int i = 0; i < sortedNotes.length; i++) {
      final note = sortedNotes[i];
      final isLeftPage = i.isEven;

      pw.MemoryImage? pdfImage;

      if (note.imagePath != null && note.imagePath!.trim().isNotEmpty) {
        final imageFile = File(note.imagePath!);
        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();
          pdfImage = pw.MemoryImage(bytes);
        }
      }

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

  static pw.Page _buildCoverPage(Notebook notebook, int noteCount) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
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
                pw.Spacer()
              ],
            ),
          ),
        );
      },
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
              pw.Container(
                width: double.infinity,
                height: 280,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _border),
                  color: PdfColors.grey100,
                ),
                child: image != null
                    ? pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
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
              ),

              pw.SizedBox(height: 20),

              pw.SizedBox(height: 8),

              pw.Container(
                width: double.infinity,
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
            ],
          ),
        ),

        pw.SizedBox(height: 16),
        _buildFooter(pageNumber, totalPages),
      ],
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
}