import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_config.dart';
import '../data/data_manager.dart' show DisplaySettings;
import '../l10n/app_strings.dart';
import '../models/seat_table.dart';
import '../state/providers.dart';
import '../state/seating_controller.dart';
import '../widgets/grid_painter.dart';
import '../widgets/table_widget.dart';
import '../widgets/text_measure.dart';
import '../widgets/trash_can.dart';

class SeatingCanvas extends ConsumerWidget {
  const SeatingCanvas({
    super.key,
    required this.strings,
    required this.className,
    required this.onTableDeleted,
  });

  final AppStrings strings;
  final String className;

  /// Called after a desk was deleted by dragging it onto the trash can, so
  /// the caller can show a short confirmation message.
  final void Function(int seatCount) onTableDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(seatingControllerProvider);
    final settings = ref.watch(settingsControllerProvider).displaySettings;

    return LayoutBuilder(
      builder: (context, constraints) {
        double canvasWidth;
        double canvasHeight;
        if (constraints.maxWidth / constraints.maxHeight >
            AppConfig.dinA4Ratio) {
          canvasHeight = constraints.maxHeight;
          canvasWidth = canvasHeight * AppConfig.dinA4Ratio;
        } else {
          canvasWidth = constraints.maxWidth;
          canvasHeight = canvasWidth / AppConfig.dinA4Ratio;
        }
        controller.updateCanvasSize(canvasWidth, canvasHeight);
        final offsetX = (constraints.maxWidth - canvasWidth) / 2;
        final offsetY = (constraints.maxHeight - canvasHeight) / 2;

        return Stack(
          children: [
            Container(color: Colors.grey[300]),
            Positioned(
              left: offsetX,
              top: offsetY,
              child: Container(
                width: canvasWidth,
                height: canvasHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (settings.gridVisible)
                      CustomPaint(
                        painter: const GridPainter(
                          gridSize: AppConfig.gridSize,
                        ),
                        size: Size(canvasWidth, canvasHeight),
                      ),
                    ...controller.tables.map(
                      (table) => _DraggableTable(
                        table: table,
                        constraints: BoxConstraints(
                          maxWidth: canvasWidth,
                          maxHeight: canvasHeight,
                        ),
                        controller: controller,
                        settings: settings,
                        strings: strings,
                        onTableDeleted: onTableDeleted,
                      ),
                    ),
                    if (settings.trashCanEnabled)
                      TrashCan(canvasSize: Size(canvasWidth, canvasHeight)),
                    if (settings.classLabelVisible)
                      Positioned(
                        child: Container(
                          height: 33,
                          width: measureTextWidth(className, 20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 2),
                              right: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                className,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DraggableTable extends StatelessWidget {
  const _DraggableTable({
    required this.table,
    required this.constraints,
    required this.controller,
    required this.settings,
    required this.strings,
    required this.onTableDeleted,
  });

  final SeatTable table;
  final BoxConstraints constraints;
  final SeatingController controller;
  final DisplaySettings settings;
  final AppStrings strings;
  final void Function(int seatCount) onTableDeleted;

  @override
  Widget build(BuildContext context) {
    final width = AppConfig.tableWidth(table.seatCount, table.direction);
    final height = AppConfig.tableHeight(table.seatCount, table.direction);

    return Positioned(
      left: table.position.dx,
      top: table.position.dy,
      child: GestureDetector(
        onPanStart: controller.swapModeActive
            ? null
            : (_) => controller.setDraggedTable(table.id),
        onPanUpdate: controller.swapModeActive
            ? null
            : (details) {
                final maxX = AppConfig.maxGridX * AppConfig.gridSize;
                final maxY = AppConfig.maxGridY * AppConfig.gridSize;
                final newPosition = Offset(
                  (table.position.dx + details.delta.dx).clamp(
                    0.0,
                    min(constraints.maxWidth - width, maxX - width),
                  ),
                  (table.position.dy + details.delta.dy).clamp(
                    0.0,
                    min(constraints.maxHeight - height, maxY - height),
                  ),
                );
                if (!controller.wouldOverlap(table, newPosition)) {
                  controller.moveTable(table, newPosition);
                }
              },
        onPanEnd: controller.swapModeActive
            ? null
            : (_) async {
                final overTrash = controller.isOverTrashCan(
                  table.position,
                  Size(constraints.maxWidth, constraints.maxHeight),
                  table,
                  trashCanEnabled: settings.trashCanEnabled,
                );
                if (overTrash) {
                  final seatCount = table.seatCount;
                  await controller.deleteTable(table.id);
                  onTableDeleted(seatCount);
                } else {
                  controller.moveTable(
                    table,
                    controller.snapToGrid(table.position),
                  );
                  await controller.persistTables();
                }
                controller.setDraggedTable(null);
              },
        onLongPress: controller.swapModeActive
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(
                      strings.tableDeleteConfirmTitle(table.seatCount),
                    ),
                    content: Text(
                      strings.tableDeleteConfirmBody(table.seatCount),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(strings.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          controller.deleteTable(table.id);
                        },
                        child: Text(
                          strings.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
        child: TableWidget(
          table: table,
          isDragging: controller.draggedTableId == table.id,
          swapModeActive: controller.swapModeActive,
          firstSwapPickTableId: controller.firstSwapPickTableId,
          firstSwapPickSeatIndex: controller.firstSwapPickSeatIndex,
          onSeatTap: controller.swapModeActive
              ? (seatIndex) =>
                    controller.handleSeatTapForSwap(table.id, seatIndex)
              : null,
          fixedSeatIndices: controller.fixedSeats
              .where((f) => f.allowedSeats.any((p) => p['tableId'] == table.id))
              .expand(
                (f) => f.allowedSeats
                    .where((p) => p['tableId'] == table.id)
                    .map((p) => p['seatIndex'] as int),
              )
              .toSet(),
        ),
      ),
    );
  }
}
