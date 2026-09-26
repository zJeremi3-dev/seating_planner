import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../models/favorite_pair.dart';
import '../models/fixed_seat.dart';
import '../models/school_class.dart';
import '../models/seat_table.dart';
import '../models/taboo_pair.dart';

/// Display toggles that used to be three loose [Switch] widgets on the
/// home screen. Bundled into one object so they can be loaded/saved in a
/// single round trip.
class DisplaySettings {
  const DisplaySettings({
    this.trashCanEnabled = true,
    this.gridVisible = true,
    this.classLabelVisible = false,
  });

  final bool trashCanEnabled;
  final bool gridVisible;
  final bool classLabelVisible;

  DisplaySettings copyWith({
    bool? trashCanEnabled,
    bool? gridVisible,
    bool? classLabelVisible,
  }) {
    return DisplaySettings(
      trashCanEnabled: trashCanEnabled ?? this.trashCanEnabled,
      gridVisible: gridVisible ?? this.gridVisible,
      classLabelVisible: classLabelVisible ?? this.classLabelVisible,
    );
  }

  List<bool> toList() => [trashCanEnabled, gridVisible, classLabelVisible];

  factory DisplaySettings.fromList(List<bool> values) {
    if (values.length < 3) return const DisplaySettings();
    return DisplaySettings(
      trashCanEnabled: values[0],
      gridVisible: values[1],
      classLabelVisible: values[2],
    );
  }
}

/// The only class in the app that talks to [SharedPreferences].
///
/// Every read/write goes through here so widgets and controllers never
/// depend on the storage mechanism directly - if the app ever moves to a
/// database or a backend, only this file changes.
class DataManager {
  DataManager._();

  static String _tablesKey(String classId) => 'tables_$classId';
  static String _studentsKey(String classId) => 'students_$classId';
  static String _tabooKey(String classId) => 'taboo_$classId';
  static String _favoritesKey(String classId) => 'favorites_$classId';
  static String _fixedSeatsKey(String classId) => 'fixed_seats_$classId';

  static const String _keyDisplaySettings = 'display_settings';
  static const String _keyClasses = 'classes';
  static const String _keyLastClassId = 'last_class_id';
  static const String _keyLanguage = 'language';

  // Tables ------------------------------------------------------------
  static Future<void> saveTables(List<SeatTable> tables, String classId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tables.map((t) => t.toJson()).toList();
    await prefs.setString(_tablesKey(classId), json.encode(jsonList));
  }

  static Future<List<SeatTable>> loadTables(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tablesKey(classId));
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((j) => SeatTable.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Students ------------------------------------------------------------
  static Future<void> saveStudents(
    List<String> students,
    String classId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_studentsKey(classId), students);
  }

  static Future<List<String>> loadStudents(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_studentsKey(classId)) ?? [];
  }

  // Fixed seats -----------------------------------------------------------
  static Future<void> saveFixedSeats(
    List<FixedSeat> fixedSeats,
    String classId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = fixedSeats.map((f) => f.toJson()).toList();
    await prefs.setString(_fixedSeatsKey(classId), json.encode(jsonList));
  }

  static Future<List<FixedSeat>> loadFixedSeats(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_fixedSeatsKey(classId));
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((j) => FixedSeat.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Taboo pairs ------------------------------------------------------------
  static Future<void> saveTabooPairs(
    List<TabooPair> pairs,
    String classId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = pairs.map((p) => p.toJson()).toList();
    await prefs.setString(_tabooKey(classId), json.encode(jsonList));
  }

  static Future<List<TabooPair>> loadTabooPairs(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tabooKey(classId));
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((j) => TabooPair.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Favorite pairs ----------------------------------------------------------
  static Future<void> saveFavoritePairs(
    List<FavoritePair> pairs,
    String classId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = pairs.map((p) => p.toJson()).toList();
    await prefs.setString(_favoritesKey(classId), json.encode(jsonList));
  }

  static Future<List<FavoritePair>> loadFavoritePairs(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey(classId));
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((j) => FavoritePair.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Classes -------------------------------------------------------------
  static Future<void> saveClasses(List<SchoolClass> classes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = classes.map((c) => c.toJson()).toList();
    await prefs.setString(_keyClasses, json.encode(jsonList));
  }

  static Future<List<SchoolClass>> loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyClasses);
    if (jsonString == null) return [];
    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((j) => SchoolClass.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLastClassId(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastClassId, classId);
  }

  static Future<String?> loadLastClassId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastClassId);
  }

  /// Removes every piece of data stored for one class.
  static Future<void> deleteClassData(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tablesKey(classId));
    await prefs.remove(_studentsKey(classId));
    await prefs.remove(_tabooKey(classId));
    await prefs.remove(_favoritesKey(classId));
    await prefs.remove(_fixedSeatsKey(classId));
  }

  // Display settings --------------------------------------------------------
  static Future<void> saveDisplaySettings(DisplaySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplaySettings, json.encode(settings.toList()));
  }

  static Future<DisplaySettings> loadDisplaySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDisplaySettings);
    if (jsonString == null) return const DisplaySettings();
    try {
      final jsonList = (json.decode(jsonString) as List).cast<bool>();
      return DisplaySettings.fromList(jsonList);
    } catch (_) {
      return const DisplaySettings();
    }
  }

  // Language --------------------------------------------------------------
  static Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language.code);
  }

  static Future<AppLanguage> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLanguage.fromCode(prefs.getString(_keyLanguage));
  }
}
