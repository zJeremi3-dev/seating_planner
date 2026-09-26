import 'package:flutter/foundation.dart';

import '../data/data_manager.dart';
import '../l10n/app_language.dart';

/// Holds the small set of app-wide preferences: which display toggles are
/// on, and which language the UI is shown in. Dark mode is intentionally
/// not modeled here yet - see the README for why it was postponed.
class SettingsController extends ChangeNotifier {
  DisplaySettings displaySettings = const DisplaySettings();
  AppLanguage language = AppLanguage.german;
  bool isLoaded = false;

  Future<void> load() async {
    displaySettings = await DataManager.loadDisplaySettings();
    language = await DataManager.loadLanguage();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> setTrashCanEnabled(bool enabled) async {
    displaySettings = displaySettings.copyWith(trashCanEnabled: enabled);
    notifyListeners();
    await DataManager.saveDisplaySettings(displaySettings);
  }

  Future<void> setGridVisible(bool visible) async {
    displaySettings = displaySettings.copyWith(gridVisible: visible);
    notifyListeners();
    await DataManager.saveDisplaySettings(displaySettings);
  }

  Future<void> setClassLabelVisible(bool visible) async {
    displaySettings = displaySettings.copyWith(classLabelVisible: visible);
    notifyListeners();
    await DataManager.saveDisplaySettings(displaySettings);
  }

  Future<void> setLanguage(AppLanguage newLanguage) async {
    language = newLanguage;
    notifyListeners();
    await DataManager.saveLanguage(newLanguage);
  }
}
