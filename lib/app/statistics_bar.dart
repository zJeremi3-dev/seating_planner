import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

class StatisticsBar extends StatelessWidget {
  const StatisticsBar({
    super.key,
    required this.strings,
    required this.studentCount,
    required this.tableCount,
    required this.seatCount,
    required this.tabooCount,
    required this.favoriteCount,
    required this.fixedSeatCount,
    required this.swapModeActive,
    required this.swapModeWaitingForSecondPick,
  });

  final AppStrings strings;
  final int studentCount;
  final int tableCount;
  final int seatCount;
  final int tabooCount;
  final int favoriteCount;
  final int fixedSeatCount;
  final bool swapModeActive;
  final bool swapModeWaitingForSecondPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(
            strings.studentsCount(studentCount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            strings.tablesCount(tableCount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            strings.seatsCount(seatCount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            strings.tabooCount(tabooCount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            strings.favoriteCount(favoriteCount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (fixedSeatCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                strings.fixedSeatsBadge(fixedSeatCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (swapModeActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: swapModeWaitingForSecondPick
                    ? Colors.orange
                    : Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                swapModeWaitingForSecondPick
                    ? strings.swapModePickSecondBadge
                    : strings.swapModeActiveBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
