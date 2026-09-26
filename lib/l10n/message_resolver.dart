import 'app_strings.dart';

/// [SeatingController] does not depend on Flutter or on [AppStrings]
/// directly (that would pull localization into supposedly pure business
/// logic) so it reports events as small string codes instead, e.g.
/// `'too_many_students:23:20'`. This function is the single place that
/// turns such a code back into user-facing, localized text.
String resolveControllerMessage(String code, AppStrings strings) {
  if (code == 'no_free_spot') return strings.msgNoFreeSpot;
  if (code == 'all_tables_deleted') return strings.allTablesDeletedMsg;
  if (code == 'swap_mode_started') return strings.swapModeStartedMsg;
  if (code == 'swap_first_picked_empty') {
    return strings.swapModeFirstPickedMsg(strings.emptySeatLabel);
  }
  if (code.startsWith('swap_first_picked:')) {
    final name = code.substring('swap_first_picked:'.length);
    return strings.swapModeFirstPickedMsg(name);
  }
  if (code == 'swap_selection_cleared') {
    return strings.swapModeSelectionClearedMsg;
  }
  if (code == 'swap_done') return strings.swapDoneMsg;
  if (code == 'no_students') return strings.noStudentsMsg;
  if (code == 'no_tables') return strings.noTablesMsg;
  if (code.startsWith('too_many_students:')) {
    final parts = code.split(':');
    final studentCount = int.tryParse(parts[1]) ?? 0;
    final seatTotal = int.tryParse(parts[2]) ?? 0;
    return strings.tooManyStudentsMsg(studentCount, seatTotal);
  }
  if (code == 'seating_created') return strings.seatingCreatedMsg;
  if (code == 'no_valid_seating') return strings.noValidSeatingMsg;
  return code;
}
