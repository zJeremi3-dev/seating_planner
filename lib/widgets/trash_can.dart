import 'package:flutter/material.dart';

import '../data/app_config.dart';

/// Visual drop target: dragging a desk here deletes it (see
/// [SeatingController.isOverTrashCan]).
class TrashCan extends StatelessWidget {
  const TrashCan({super.key, required this.canvasSize});

  final Size canvasSize;

  @override
  Widget build(BuildContext context) {
    final x =
        canvasSize.width - AppConfig.trashCanSize - AppConfig.trashCanMargin;
    final y =
        canvasSize.height - AppConfig.trashCanSize - AppConfig.trashCanMargin;
    return Positioned(
      left: x,
      top: y,
      child: Container(
        width: AppConfig.trashCanSize,
        height: AppConfig.trashCanSize,
        decoration: BoxDecoration(
          color: AppConfig.trashCanColor.withValues(alpha: 0.2),
          border: Border.all(color: AppConfig.trashCanColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.delete_forever,
          size: 36,
          color: AppConfig.trashCanColor,
        ),
      ),
    );
  }
}
