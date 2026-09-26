import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_strings.dart';
import 'classes_controller.dart';
import 'seating_controller.dart';
import 'settings_controller.dart';

/// The list of saved classes and which one is selected.
final classesControllerProvider = ChangeNotifierProvider<ClassesController>(
  (ref) => ClassesController()..load(),
);

/// Desks/students/rules for the currently open class.
final seatingControllerProvider = ChangeNotifierProvider<SeatingController>(
  (ref) => SeatingController(),
);

/// Display toggles + language.
final settingsControllerProvider = ChangeNotifierProvider<SettingsController>(
  (ref) => SettingsController()..load(),
);

/// Convenience provider: the strings for whatever language is currently
/// selected. Watch this instead of reaching into [settingsControllerProvider]
/// everywhere a widget just needs text.
final appStringsProvider = Provider<AppStrings>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  return AppStrings(settings.language);
});
