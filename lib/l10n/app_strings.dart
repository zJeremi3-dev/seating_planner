import 'app_language.dart';

/// Central lookup for every user-facing string in the app.
///
/// Rather than generating ARB/`intl` boilerplate for two languages, each
/// piece of text is written once as a small `_t(german, english)` pair.
/// This keeps every string next to its translation, which makes it easy
/// to audit and to add a third language later if needed.
class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  bool get _isGerman => language == AppLanguage.german;

  String _t(String german, String english) => _isGerman ? german : english;

  // App shell -----------------------------------------------------------
  String get appTitle =>
      _t('Sitzordnungs-Randomizer', 'Seating Plan Randomizer');
  String get switchClassTooltip => _t('Klasse wechseln', 'Switch class');
  String get settingsTooltip => _t('Einstellungen', 'Settings');

  // Button bar ------------------------------------------------------------
  String get addTable2Horizontal => _t('2er-Tisch ⇆', '2-seat desk ⇆');
  String get addTable1 => _t('1er-Tisch', '1-seat desk');
  String get addTable2Vertical => _t('2er-Tisch ⇵', '2-seat desk ⇵');
  String get openNameList => _t('Namensliste', 'Student list');
  String get openPairs => _t('Paare', 'Pairs');
  String get startRandomizer => _t('Randomizer', 'Randomizer');
  String get startSwapMode => _t('Tausch-Modus', 'Swap mode');
  String get endSwapMode => _t('Tausch beenden', 'End swap');
  String get deleteAllTables => _t('Alle löschen', 'Delete all');
  String get printPlan => _t('Drucken', 'Print');
  String get helpTooltip => _t('Handbuch', 'Manual');

  // Statistics bar ----------------------------------------------------------
  String studentsCount(int n) => _t('Schüler/innen: $n', 'Students: $n');
  String tablesCount(int n) => _t('Tische: $n', 'Desks: $n');
  String seatsCount(int n) => _t('Plätze: $n', 'Seats: $n');
  String tabooCount(int n) => _t('Tabu-Paare: $n', 'Taboo pairs: $n');
  String favoriteCount(int n) =>
      _t('Favoriten-Paare: $n', 'Favorite pairs: $n');
  String fixedSeatsBadge(int n) =>
      _t('📌 $n feste Plätze', '📌 $n fixed seats');
  String get swapModeActiveBadge =>
      _t('🔄 Tausch-Modus aktiv', '🔄 Swap mode active');
  String get swapModePickSecondBadge =>
      _t('🔄 Zweiten Platz wählen...', '🔄 Choose the second seat...');

  // Canvas / table area -----------------------------------------------------
  String get noTablesHint => _t(
    'Keine Tische vorhanden.\nFüge Tische mit den Buttons oben hinzu.',
    'No desks yet.\nAdd desks with the buttons above.',
  );
  String tableDeleteConfirmTitle(int seatCount) =>
      _t('Tisch löschen?', 'Delete desk?');
  String tableDeleteConfirmBody(int seatCount) => _t(
    'Möchtest du diesen $seatCount er-Tisch wirklich löschen?',
    'Do you really want to delete this $seatCount-seat desk?',
  );
  String get cancel => _t('Abbrechen', 'Cancel');
  String get delete => _t('Löschen', 'Delete');
  String get save => _t('Speichern', 'Save');
  String get close => _t('Schließen', 'Close');
  String get apply => _t('Übernehmen', 'Apply');
  String get rename => _t('Umbenennen', 'Rename');
  String get add => _t('Hinzufügen', 'Add');

  // Messages (snack bars) ---------------------------------------------------
  String get msgNoFreeSpot => _t(
    'Kein freier Platz gefunden! Bitte lösche zuerst einige Tische.',
    'No free spot found! Please delete some desks first.',
  );
  String tableDeletedMsg(int seatCount) =>
      _t('$seatCount er-Tisch gelöscht', '$seatCount-seat desk deleted');
  String get allTablesDeletedMsg =>
      _t('Alle Tische wurden gelöscht', 'All desks were deleted');
  String get noStudentsMsg =>
      _t('Keine Schüler in der Namensliste!', 'No students in the list!');
  String get noTablesMsg => _t('Keine Tische vorhanden!', 'No desks yet!');
  String tooManyStudentsMsg(int studentCount, int seatTotal) => _t(
    'Zu viele Schüler! ($studentCount Schüler, aber nur $seatTotal Plätze)',
    'Too many students! ($studentCount students, only $seatTotal seats)',
  );
  String get seatingCreatedMsg =>
      _t('Sitzordnung erstellt!', 'Seating plan created!');
  String get noValidSeatingMsg => _t(
    'Keine gültige Sitzordnung gefunden! Prüfe die Tabu-Liste.',
    'No valid seating plan found! Check the taboo list.',
  );
  String get swapModeStartedMsg => _t(
    'Tausch-Modus aktiv: Ersten Schüler auswählen',
    'Swap mode active: choose the first student',
  );
  String swapModeFirstPickedMsg(String name) => _t(
    '$name ausgewählt – jetzt zweiten Platz wählen',
    '$name selected - now choose the second seat',
  );
  String get swapModeSelectionClearedMsg =>
      _t('Auswahl aufgehoben', 'Selection cleared');
  String get swapDoneMsg => _t('Schüler getauscht!', 'Students swapped!');
  String get emptySeatLabel => _t('(leerer Platz)', '(empty seat)');
  String get pleaseAddStudentsMsg => _t(
    'Bitte zuerst Schüler zur Namensliste hinzufügen!',
    'Please add students to the list first!',
  );
  String get noTablesToPrintMsg =>
      _t('Keine Tische zum Drucken vorhanden', 'No desks to print');

  // Class chip / rename dialog ------------------------------------------
  String get renameClassTitle => _t('Klasse umbenennen', 'Rename class');
  String get newClassNameLabel => _t('Neuer Klassenname', 'New class name');

  // Settings --------------------------------------------------------------
  String get settingsTitle => _t('Einstellungen', 'Settings');
  String get settingsLanguageSection => _t('Sprache', 'Language');
  String get settingsDisplaySection => _t('Anzeige', 'Display');
  String get settingsDisplayHint => _t(
    'Mülleimer, Raster und Klassenname lassen sich unten am Arbeitsbereich ein-/ausschalten.',
    'Trash can, grid and class label can be toggled below the working area.',
  );
  String get settingsGerman => _t('Deutsch', 'German');
  String get settingsEnglish => _t('Englisch', 'English');
  String get settingsTrashCanLabel => _t('Mülleimer', 'Trash can');
  String get settingsTrashCanHint => _t(
    'Tische zum Löschen dorthin ziehen.',
    'Drag desks there to delete them.',
  );
  String get settingsGridLabel => _t('Raster anzeigen', 'Show grid');
  String get settingsGridHint => _t(
    'Tische rasten immer ein, auch wenn das Raster ausgeblendet ist.',
    'Desks always snap to the grid, even when it is hidden.',
  );
  String get settingsClassLabelLabel =>
      _t('Klassenname anzeigen', 'Show class name');
  String get settingsClassLabelHint => _t(
    'Zeigt den Klassennamen oben links auf dem Plan (auch beim Drucken).',
    'Shows the class name in the top-left corner of the plan (also when printing).',
  );
  String get settingsDarkModeLabel => _t('Dunkelmodus', 'Dark mode');
  String get settingsDarkModeComingSoon =>
      _t('Kommt in einem späteren Update', 'Coming in a later update');

  // Name / student editor ---------------------------------------------------
  String get nameEditorTitle =>
      _t('Namensliste bearbeiten', 'Edit student list');
  String get searchStudentLabel => _t('Schüler suchen', 'Search students');
  String get studentNameLabel => _t('Name', 'Name');
  String get noStudentsInList =>
      _t('Keine Schüler in der Liste', 'No students in the list');
  String get noStudentsFound =>
      _t('Keine Schüler gefunden', 'No students found');
  String get removeFixedSeatTooltip =>
      _t('Festen Platz entfernen', 'Remove fixed seat');
  String get configureSeatTooltip =>
      _t('Platz konfigurieren', 'Configure seat');
  String fixedSeatSummary(int count) => count == 1
      ? _t('📌 1 fester Platz', '📌 1 fixed seat')
      : _t('📌 $count erlaubte Plätze', '📌 $count allowed seats');
  String fixedRowSummary(int count) => count == 1
      ? _t('🏠 1 feste Reihe', '🏠 1 fixed row')
      : _t('🏠 $count erlaubte Reihen', '🏠 $count allowed rows');
  String get noFixedSeat => _t('Kein fester Platz', 'No fixed seat');

  // Seat selection dialog ---------------------------------------------------
  String seatSelectionTitle(String studentName) =>
      _t('Platz für $studentName wählen', 'Choose a seat for $studentName');
  String get seatSelectionRowLegend =>
      _t('Feste Reihe(n) wählen', 'Choose fixed row(s)');
  String get seatSelectionSeatLegend =>
      _t('Plätze antippen (mehrere möglich)', 'Tap seats (multiple possible)');
  String seatsSelectedFooter(int count) => count == 1
      ? _t('📌 1 Platz gewählt', '📌 1 seat selected')
      : _t('📌 $count Plätze gewählt', '📌 $count seats selected');
  String rowsSelectedFooter(int count) => count == 1
      ? _t('🏠 1 Reihe gewählt', '🏠 1 row selected')
      : _t('🏠 $count Reihen gewählt', '🏠 $count rows selected');
  String get nothingSelectedFooter => _t(
    'Nichts gewählt – kein fester Platz',
    'Nothing selected - no fixed seat',
  );

  // Pair editor -------------------------------------------------------------
  String get pairEditorTitle => _t('Paare', 'Pairs');
  String get tabooFavoriteSwitchTooltip =>
      _t('Tabu — Favorit', 'Taboo — Favorite');
  String get tabooExplanation => _t(
    'Diese Schüler dürfen nicht nebeneinander sitzen:',
    'These students must not sit next to each other:',
  );
  String get tabooExplanationDetail => _t(
    '(Gilt horizontal, außer ein Tisch ist dazwischen)',
    '(Applies horizontally, unless another desk is in between)',
  );
  String get favoriteExplanation => _t(
    'Diese Schüler sollen immer nebeneinander sitzen:',
    'These students should always sit next to each other:',
  );
  String get favoriteExplanationDetail => _t(
    '(Main sitzt mit einem zufälligen Sec zusammen)',
    '(Main sits together with a randomly chosen Sec)',
  );
  String get student1Label => _t('Schüler 1', 'Student 1');
  String get student2Label => _t('Schüler 2', 'Student 2');
  String get mainStudentLabel => _t('Main', 'Main');
  String get secStudentLabel => _t('Sec', 'Sec');
  String get addTabooPair => _t('Tabu-Paar hinzufügen', 'Add taboo pair');
  String get addFavoritePair =>
      _t('Favoriten-Paar hinzufügen', 'Add favorite pair');
  String get chooseTwoDifferentStudentsMsg =>
      _t('Wähle zwei verschiedene Schüler!', 'Choose two different students!');
  String tabooBadge(int n) => _t('$n Tabu', '$n taboo');
  String favoriteBadge(int n) => _t('$n Favoriten', '$n favorites');
  String get noPairsDefined => _t('Keine Paare definiert', 'No pairs defined');
  String get tabooCardSubtitle => _t(
    'Dürfen nicht nebeneinander sitzen',
    'Must not sit next to each other',
  );
  String get favoriteCardSubtitle => _t(
    'Main sitzt zufällig mit einem Sec zusammen',
    'Main sits randomly together with a Sec',
  );
  String get addSecTooltip => _t('Weiteren Sec hinzufügen', 'Add another Sec');
  String get deleteFavoritePairTooltip =>
      _t('Ganzes Favoriten-Paar löschen', 'Delete whole favorite pair');
  String addSecDialogTitle(String mainStudent) =>
      _t('Sec hinzufügen für $mainStudent', 'Add Sec for $mainStudent');
  String get selectStudentLabel => _t('Schüler auswählen', 'Select student');
  String get noMoreStudentsAvailableMsg =>
      _t('Keine weiteren Schüler verfügbar!', 'No more students available!');

  // Class editor --------------------------------------------------------
  String get className => _t('Klassen Name', 'Class name');
  String get noClassesHint => _t(
    'Keine Klassen vorhanden.\nFüge eine Klasse hinzu!',
    'No classes yet.\nAdd a class!',
  );
  String get deleteClassTitle => _t('Klasse löschen?', 'Delete class?');
  String deleteClassBody(String name) => _t(
    'Möchtest du die Klasse "$name" wirklich löschen? Alle Tische, Namen und Regeln dieser Klasse gehen verloren.',
    'Do you really want to delete the class "$name"? All desks, names and rules for it will be lost.',
  );

  // Help / manual -----------------------------------------------------------
  String get helpDialogTitle => _t('Handbuch', 'Manual');
}
