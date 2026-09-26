import 'package:flutter/material.dart';

import '../data/app_config.dart';
import '../models/seat_table.dart';

/// The visual representation of a [SeatTable]: a rounded box split into
/// 1 or 2 seats, each showing the student's name (or `---` when empty).
class TableWidget extends StatelessWidget {
  const TableWidget({
    super.key,
    required this.table,
    this.isDragging = false,
    this.swapModeActive = false,
    this.firstSwapPickTableId,
    this.firstSwapPickSeatIndex,
    this.onSeatTap,
    this.fixedSeatIndices = const {},
  });

  final SeatTable table;
  final bool isDragging;
  final bool swapModeActive;
  final String? firstSwapPickTableId;
  final int? firstSwapPickSeatIndex;
  final void Function(int seatIndex)? onSeatTap;

  /// Seat indices that have a fixed-seat rule pointing at them; these show
  /// a small pin icon.
  final Set<int> fixedSeatIndices;

  @override
  Widget build(BuildContext context) {
    final width = AppConfig.tableWidth(table.seatCount, table.direction);
    final height = AppConfig.tableHeight(table.seatCount, table.direction);

    final tableColor = isDragging
        ? Colors.blue.withValues(alpha: 0.7)
        : AppConfig.tableColor;
    var borderColor = AppConfig.tableBorderColor;
    if (swapModeActive && firstSwapPickTableId == table.id) {
      borderColor = Colors.orange;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tableColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: swapModeActive && firstSwapPickTableId == table.id ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: table.seatCount == 2
          ? (table.direction == 'vertical'
                ? Column(
                    children: [
                      Expanded(child: _buildSeat(0)),
                      Container(height: 2, color: borderColor),
                      Expanded(child: _buildSeat(1)),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildSeat(0)),
                      Container(width: 2, color: borderColor),
                      Expanded(child: _buildSeat(1)),
                    ],
                  ))
          : _buildSeat(0),
    );
  }

  Widget _buildSeat(int seatIndex) {
    final student = table.students[seatIndex];
    final isSelected =
        swapModeActive &&
        firstSwapPickTableId == table.id &&
        firstSwapPickSeatIndex == seatIndex;
    final isFixed = fixedSeatIndices.contains(seatIndex);

    final content = Container(
      padding: const EdgeInsets.all(3),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.yellow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Stack(
        children: [
          Center(
            child: Text(
              student ?? '---',
              style: TextStyle(
                color: student != null ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isFixed)
            const Positioned(
              top: 1,
              right: 1,
              child: Icon(Icons.push_pin, size: 8, color: Colors.yellow),
            ),
        ],
      ),
    );

    if (swapModeActive && onSeatTap != null) {
      return GestureDetector(
        onTap: () => onSeatTap!(seatIndex),
        child: content,
      );
    }
    return content;
  }
}
