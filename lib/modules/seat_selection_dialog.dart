import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_config.dart';
import '../l10n/app_strings.dart';
import '../models/fixed_seat.dart';
import '../models/seat_table.dart';

class SeatSelectionResult {
  const SeatSelectionResult(this.allowedSeats, this.allowedRowIds);
  final List<Map<String, dynamic>> allowedSeats;
  final List<String> allowedRowIds;
}

class SeatSelectionDialog extends StatefulWidget {
  const SeatSelectionDialog({
    super.key,
    required this.strings,
    required this.studentName,
    required this.tables,
    required this.rows,
    required this.rowKeyFn,
    required this.initial,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  final AppStrings strings;
  final String studentName;
  final List<SeatTable> tables;
  final List<List<String>> rows;
  final String Function(List<String>) rowKeyFn;
  final FixedSeat initial;
  final double canvasWidth;
  final double canvasHeight;

  @override
  State<SeatSelectionDialog> createState() => _SeatSelectionDialogState();
}

class _RowBounds {
  const _RowBounds({required this.minY, required this.maxY});
  final double minY;
  final double maxY;
}

class _SeatSelectionDialogState extends State<SeatSelectionDialog> {
  late Set<String> _selectedSeats;
  late Set<String> _selectedRowIds;

  String _seatKey(String tableId, int seatIndex) => '$tableId|$seatIndex';

  @override
  void initState() {
    super.initState();
    _selectedSeats = widget.initial.allowedSeats
        .map((p) => _seatKey(p['tableId'] as String, p['seatIndex'] as int))
        .toSet();
    _selectedRowIds = Set.from(widget.initial.allowedRowIds);
  }

  Map<String, _RowBounds> _computeRowBounds(double scale) {
    final result = <String, _RowBounds>{};
    for (final row in widget.rows) {
      double minY = double.infinity;
      double maxY = double.negativeInfinity;
      for (final tableId in row) {
        final table = widget.tables.firstWhere((t) => t.id == tableId);
        final height = AppConfig.tableHeight(table.seatCount, table.direction);
        final top = table.position.dy * scale;
        final bottom = top + height * scale;
        if (top < minY) minY = top;
        if (bottom > maxY) maxY = bottom;
      }
      result[widget.rowKeyFn(row)] = _RowBounds(minY: minY, maxY: maxY);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.indigo,
              child: Row(
                children: [
                  const Icon(Icons.push_pin, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.seatSelectionTitle(widget.studentName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  if (widget.rows.isNotEmpty) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.seatSelectionRowLegend,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.touch_app, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    s.seatSelectionSeatLegend,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const checkboxWidth = 45.0;
                  const padding = 32.0;
                  final rowsExist = widget.rows.isNotEmpty;

                  final availableWidth =
                      constraints.maxWidth -
                      padding -
                      (rowsExist ? checkboxWidth : 0);
                  final availableHeight = constraints.maxHeight - 16;

                  final scaleX = availableWidth / widget.canvasWidth;
                  final scaleY = availableHeight / widget.canvasHeight;
                  final scale = min(scaleX, scaleY);

                  final planWidth = widget.canvasWidth * scale;
                  final planHeight = widget.canvasHeight * scale;
                  final rowBounds = _computeRowBounds(scale);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rowsExist)
                          SizedBox(
                            width: checkboxWidth - 4,
                            height: planHeight,
                            child: Stack(
                              children: widget.rows.map((row) {
                                final key = widget.rowKeyFn(row);
                                final isSelected = _selectedRowIds.contains(
                                  key,
                                );
                                final bounds = rowBounds[key]!;
                                final centerY = (bounds.minY + bounds.maxY) / 2;
                                const boxHeight = 44.0;
                                return Positioned(
                                  top: (centerY - boxHeight / 2).clamp(
                                    0.0,
                                    planHeight - boxHeight,
                                  ),
                                  left: 0,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      if (isSelected) {
                                        _selectedRowIds.remove(key);
                                      } else {
                                        _selectedRowIds.add(key);
                                        _selectedSeats.clear();
                                      }
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.indigo.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.grey.withValues(
                                                alpha: 0.06,
                                              ),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.indigo
                                              : Colors.grey.withValues(
                                                  alpha: 0.4,
                                                ),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: isSelected,
                                          activeColor: Colors.indigo,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          onChanged: (checked) => setState(() {
                                            if (checked == true) {
                                              _selectedRowIds.add(key);
                                              _selectedSeats.clear();
                                            } else {
                                              _selectedRowIds.remove(key);
                                            }
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (rowsExist) const SizedBox(width: 4),
                        SizedBox(
                          width: planWidth,
                          height: planHeight,
                          child: Stack(
                            children: [
                              Container(
                                width: planWidth,
                                height: planHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                              // Highlight all selected rows.
                              ...widget.rows.map((row) {
                                final key = widget.rowKeyFn(row);
                                final isSelected = _selectedRowIds.contains(
                                  key,
                                );
                                if (!isSelected) return const SizedBox.shrink();
                                final bounds = rowBounds[key]!;
                                double minX = double.infinity;
                                double maxX = double.negativeInfinity;
                                for (final tableId in row) {
                                  final table = widget.tables.firstWhere(
                                    (t) => t.id == tableId,
                                  );
                                  final width = AppConfig.tableWidth(
                                    table.seatCount,
                                    table.direction,
                                  );
                                  final left = table.position.dx * scale;
                                  final right = left + width * scale;
                                  if (left < minX) minX = left;
                                  if (right > maxX) maxX = right;
                                }
                                return Positioned(
                                  left: minX - 4,
                                  top: bounds.minY - 4,
                                  width: (maxX - minX) + 8,
                                  height: (bounds.maxY - bounds.minY) + 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withValues(
                                        alpha: 0.08,
                                      ),
                                      border: Border.all(
                                        color: Colors.indigo.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                );
                              }),
                              ...widget.tables.map((table) {
                                final width = AppConfig.tableWidth(
                                  table.seatCount,
                                  table.direction,
                                );
                                final height = AppConfig.tableHeight(
                                  table.seatCount,
                                  table.direction,
                                );
                                return Positioned(
                                  left: table.position.dx * scale,
                                  top: table.position.dy * scale,
                                  child: _buildInteractiveTable(
                                    table,
                                    width * scale,
                                    height * scale,
                                    scale,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: const Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedSeats.isNotEmpty
                          ? s.seatsSelectedFooter(_selectedSeats.length)
                          : _selectedRowIds.isNotEmpty
                          ? s.rowsSelectedFooter(_selectedRowIds.length)
                          : s.nothingSelectedFooter,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            (_selectedSeats.isNotEmpty ||
                                _selectedRowIds.isNotEmpty)
                            ? Colors.indigo
                            : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(s.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final seats = _selectedSeats.map((key) {
                        final parts = key.split('|');
                        return {
                          'tableId': parts[0],
                          'seatIndex': int.parse(parts[1]),
                        };
                      }).toList();
                      Navigator.pop(
                        context,
                        SeatSelectionResult(seats, _selectedRowIds.toList()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(s.apply),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveTable(
    SeatTable table,
    double width,
    double height,
    double scale,
  ) {
    final hasSelectedSeat = table.seatCount == 1
        ? _selectedSeats.contains(_seatKey(table.id, 0))
        : _selectedSeats.contains(_seatKey(table.id, 0)) ||
              _selectedSeats.contains(_seatKey(table.id, 1));
    final borderColor = hasSelectedSeat
        ? Colors.indigo
        : AppConfig.tableBorderColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppConfig.tableColor,
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: borderColor, width: hasSelectedSeat ? 3 : 2),
        boxShadow: hasSelectedSeat
            ? [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: table.seatCount == 2
          ? (table.direction == 'vertical'
                ? Column(
                    children: [
                      Expanded(child: _buildInteractiveSeat(table, 0, scale)),
                      Container(height: 2, color: borderColor),
                      Expanded(child: _buildInteractiveSeat(table, 1, scale)),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildInteractiveSeat(table, 0, scale)),
                      Container(width: 2, color: borderColor),
                      Expanded(child: _buildInteractiveSeat(table, 1, scale)),
                    ],
                  ))
          : _buildInteractiveSeat(table, 0, scale),
    );
  }

  Widget _buildInteractiveSeat(SeatTable table, int seatIndex, double scale) {
    final key = _seatKey(table.id, seatIndex);
    final isSelected = _selectedSeats.contains(key);

    String label;
    if (isSelected) {
      label = '✓';
    } else if (table.seatCount == 2) {
      label = table.direction == 'vertical'
          ? (seatIndex == 0 ? '↑' : '↓')
          : (seatIndex == 0 ? '←' : '→');
    } else {
      label = '●';
    }

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedSeats.remove(key);
        } else {
          _selectedSeats.add(key);
          _selectedRowIds.clear();
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.indigo.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4 * scale),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
