import 'package:flutter/material.dart';

/// A desk placed on the seating canvas.
///
/// A [SeatTable] has 1 or 2 seats ([seatCount]), a [position] on the grid,
/// and a [direction] that decides how a 2-seat desk is split
/// ("horizontal" -> side by side, "vertical" -> stacked).
class SeatTable {
  String id;
  int seatCount;
  Offset position;
  List<String?> students;
  String direction;

  SeatTable({
    required this.id,
    required this.seatCount,
    required this.position,
    this.direction = 'horizontal',
  }) : students = List.filled(seatCount, null);

  Map<String, dynamic> toJson() => {
    'id': id,
    'seatCount': seatCount,
    'x': position.dx,
    'y': position.dy,
    'students': students,
    'direction': direction,
  };

  factory SeatTable.fromJson(Map<String, dynamic> json) {
    final table = SeatTable(
      id: json['id'] as String,
      seatCount: json['seatCount'] as int,
      position: Offset(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      direction: json['direction'] as String? ?? 'horizontal',
    );
    table.students = List<String?>.from(json['students'] as List);
    return table;
  }
}
