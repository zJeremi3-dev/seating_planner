import 'package:flutter/material.dart';

/// Returns the pixel width [text] would need at [fontSize], plus a little
/// padding. Used to size badges/snackbars that should hug their content.
double measureTextWidth(String text, double fontSize) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return painter.width + 30;
}
