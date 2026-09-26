import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'app_config.dart';
import '../models/seat_table.dart';

/// Renders the current seating plan as a landscape A4 PDF and hands it to
/// the platform's print/share dialog.
Future<void> exportSeatingPlanPdf({
  required List<SeatTable> tables,
  required double canvasWidth,
  required double canvasHeight,
  required bool showClassLabel,
  required String className,
}) async {
  final document = pw.Document();
  final pageWidth = PdfPageFormat.a4.landscape.width;
  final pageHeight = PdfPageFormat.a4.landscape.height;
  const margin = 20.0;

  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(margin),
      build: (pw.Context context) {
        final availableWidth = pageWidth - (2 * margin);
        final availableHeight = pageHeight - (2 * margin);
        final scaleX = availableWidth / canvasWidth;
        final scaleY = availableHeight / canvasHeight;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        return pw.Stack(
          children: [
            ...tables.map((table) {
              final width = AppConfig.tableWidth(
                table.seatCount,
                table.direction,
              );
              final height = AppConfig.tableHeight(
                table.seatCount,
                table.direction,
              );
              return pw.Positioned(
                left: table.position.dx * scale,
                top: table.position.dy * scale,
                child: pw.Container(
                  width: width * scale,
                  height: height * scale,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.brown300,
                    border: pw.Border.all(color: PdfColors.brown700, width: 2),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: table.seatCount == 2
                      ? (table.direction == 'vertical'
                            ? pw.Column(
                                children: [
                                  pw.Expanded(
                                    child: _buildPdfSeat(
                                      table.students[0],
                                      scale,
                                    ),
                                  ),
                                  pw.Container(
                                    height: 2,
                                    color: PdfColors.brown700,
                                  ),
                                  pw.Expanded(
                                    child: _buildPdfSeat(
                                      table.students[1],
                                      scale,
                                    ),
                                  ),
                                ],
                              )
                            : pw.Row(
                                children: [
                                  pw.Expanded(
                                    child: _buildPdfSeat(
                                      table.students[0],
                                      scale,
                                    ),
                                  ),
                                  pw.Container(
                                    width: 2,
                                    color: PdfColors.brown700,
                                  ),
                                  pw.Expanded(
                                    child: _buildPdfSeat(
                                      table.students[1],
                                      scale,
                                    ),
                                  ),
                                ],
                              ))
                      : _buildPdfSeat(table.students[0], scale),
                ),
              );
            }),
            if (showClassLabel)
              pw.Align(
                alignment: pw.Alignment.topLeft,
                child: pw.Container(
                  height: 33,
                  width: _textWidth(className, 20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(width: 2, color: PdfColors.black),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        className,
                        style: const pw.TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );

  final bytes = await document.save();
  if (kIsWeb) {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  } else {
    await Printing.sharePdf(bytes: bytes, filename: 'seating_plan.pdf');
  }
}

pw.Widget _buildPdfSeat(String? student, double scale) {
  return pw.Container(
    padding: pw.EdgeInsets.all(3 * scale),
    child: pw.Center(
      child: pw.Text(
        student ?? '---',
        style: pw.TextStyle(
          color: student != null ? PdfColors.white : PdfColors.grey600,
          fontWeight: pw.FontWeight.bold,
          fontSize: 12 * scale,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

/// Rough width estimate for the class-name badge (pdf package has no
/// TextPainter, so this mirrors the app's own `_getTextWidth` heuristic).
double _textWidth(String text, double fontSize) {
  return text.length * fontSize * 0.6 + 30;
}
