import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

class SeatingBottomBar extends StatelessWidget {
  const SeatingBottomBar({
    super.key,
    required this.strings,
    required this.classLabelVisible,
    required this.trashCanEnabled,
    required this.gridVisible,
    required this.onClassLabelChanged,
    required this.onTrashCanChanged,
    required this.onGridChanged,
    required this.onPrint,
  });

  final AppStrings strings;
  final bool classLabelVisible;
  final bool trashCanEnabled;
  final bool gridVisible;
  final ValueChanged<bool> onClassLabelChanged;
  final ValueChanged<bool> onTrashCanChanged;
  final ValueChanged<bool> onGridChanged;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Tooltip(
            message: strings.settingsClassLabelLabel,
            textAlign: TextAlign.center,
            child: Switch(
              value: classLabelVisible,
              onChanged: onClassLabelChanged,
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.text_fields, color: Colors.white);
                }
                return const Icon(Icons.text_fields, color: Colors.transparent);
              }),
              thumbColor: WidgetStateProperty.all(const Color(0xFF535353)),
              trackColor: WidgetStateProperty.all(Colors.purple[100]),
              trackOutlineColor: WidgetStateProperty.all(Colors.grey[700]),
              trackOutlineWidth: WidgetStateProperty.all(2.5),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Tooltip(
            message: strings.settingsTrashCanLabel,
            textAlign: TextAlign.center,
            child: Switch(
              value: trashCanEnabled,
              onChanged: onTrashCanChanged,
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.delete_forever, color: Colors.white);
                }
                return const Icon(
                  Icons.delete_forever,
                  color: Colors.transparent,
                );
              }),
              thumbColor: WidgetStateProperty.all(const Color(0xFF535353)),
              trackColor: WidgetStateProperty.all(Colors.red[100]),
              trackOutlineColor: WidgetStateProperty.all(Colors.grey[700]),
              trackOutlineWidth: WidgetStateProperty.all(2.5),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Tooltip(
            message: strings.settingsGridLabel,
            textAlign: TextAlign.center,
            child: Switch(
              value: gridVisible,
              onChanged: onGridChanged,
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.grid_on, color: Colors.white);
                }
                return const Icon(Icons.grid_off, color: Colors.white);
              }),
              thumbColor: WidgetStateProperty.all(const Color(0xFF535353)),
              trackColor: WidgetStateProperty.all(Colors.blue[100]),
              trackOutlineColor: WidgetStateProperty.all(Colors.grey[700]),
              trackOutlineWidth: WidgetStateProperty.all(2.5),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print, size: 25),
            label: Text(strings.printPlan),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
