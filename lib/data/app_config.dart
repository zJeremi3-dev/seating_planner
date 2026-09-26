import 'package:flutter/material.dart';

/// Central place for all "magic numbers" the app relies on.
///
/// Keeping these together makes it possible to retune the layout
/// (grid size, desk dimensions, colors, ...) without hunting through
/// widget code.
class AppConfig {
  AppConfig._();

  // Grid and desk sizes.
  static const double gridSize = 10.0;
  static const double maxGridX = 96.0;
  static const double maxGridY = 68.0;
  static const double table2WidthHorizontal = 120.0;
  static const double table2HeightHorizontal = 60.0;
  static const double table2WidthVertical = 60.0;
  static const double table2HeightVertical = 120.0;
  static const double table1Width = 60.0;
  static const double table1Height = 60.0;

  // Spacing and collision detection.
  static const double tableBuffer = 5.0; // minimum gap between desks
  static const double neighborThreshold = 50.0; // used for the taboo check

  // Randomizer.
  static const int maxAttempts = 1000;

  // Trash can (drag a desk here to delete it).
  static const double trashCanSize = 75.0;
  static const double trashCanMargin = 10.0;

  // Colors.
  static const Color tableColor = Color(0xFFA1887F); // Colors.brown[300]
  static const Color tableBorderColor = Color(0xFF5D4037); // Colors.brown[700]
  static const Color trashCanColor = Colors.red;

  // DIN A4 landscape aspect ratio (sqrt(2)).
  static const double dinA4Ratio = 1.414;

  /// Width of a desk for the given seat count and orientation.
  static double tableWidth(int seatCount, String direction) {
    if (direction == 'vertical') return table2WidthVertical;
    return seatCount == 2 ? table2WidthHorizontal : table1Width;
  }

  /// Height of a desk for the given seat count and orientation.
  static double tableHeight(int seatCount, String direction) {
    if (direction == 'vertical') return table2HeightVertical;
    return seatCount == 2 ? table2HeightHorizontal : table1Height;
  }
}
