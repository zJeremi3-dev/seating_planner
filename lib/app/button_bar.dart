import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import 'help_dialog.dart';

class SeatingButtonBar extends StatelessWidget {
  const SeatingButtonBar({
    super.key,
    required this.strings,
    required this.swapModeActive,
    required this.onAddTable2Horizontal,
    required this.onAddTable1,
    required this.onAddTable2Vertical,
    required this.onOpenNameList,
    required this.onOpenPairs,
    required this.onRunRandomizer,
    required this.onToggleSwapMode,
    required this.onDeleteAllTables,
  });

  final AppStrings strings;
  final bool swapModeActive;
  final VoidCallback onAddTable2Horizontal;
  final VoidCallback onAddTable1;
  final VoidCallback onAddTable2Vertical;
  final VoidCallback onOpenNameList;
  final VoidCallback onOpenPairs;
  final VoidCallback onRunRandomizer;
  final VoidCallback onToggleSwapMode;
  final VoidCallback onDeleteAllTables;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: onAddTable2Horizontal,
            icon: const Icon(Icons.add),
            label: Text(strings.addTable2Horizontal),
          ),
          ElevatedButton.icon(
            onPressed: onAddTable1,
            icon: const Icon(Icons.add),
            label: Text(strings.addTable1),
          ),
          ElevatedButton.icon(
            onPressed: onAddTable2Vertical,
            icon: const Icon(Icons.add),
            label: Text(strings.addTable2Vertical),
          ),
          ElevatedButton.icon(
            onPressed: onOpenNameList,
            icon: const Icon(Icons.people),
            label: Text(strings.openNameList),
          ),
          ElevatedButton(
            onPressed: onOpenPairs,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block),
                const SizedBox(width: 4),
                Text(strings.openPairs),
                const SizedBox(width: 4),
                const Icon(Icons.favorite),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onRunRandomizer,
            icon: const Icon(Icons.shuffle),
            label: Text(strings.startRandomizer),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onToggleSwapMode,
            icon: Icon(swapModeActive ? Icons.close : Icons.swap_horiz),
            label: Text(
              swapModeActive ? strings.endSwapMode : strings.startSwapMode,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: swapModeActive ? Colors.orange : Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onDeleteAllTables,
            icon: const Icon(Icons.clear),
            label: Text(strings.deleteAllTables),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          Tooltip(
            message: strings.helpTooltip,
            textAlign: TextAlign.center,
            child: ElevatedButton(
              onPressed: () => showHelpDialog(context, strings),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
              ),
              child: const Icon(Icons.menu_book, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
