import 'package:flutter/material.dart';

import 'app_language.dart';

/// One topic in the help dialog: an icon, a title and a list of
/// (subtitle, body) entries rendered underneath it.
class HelpSection {
  const HelpSection({
    required this.icon,
    required this.title,
    required this.entries,
  });

  final IconData icon;
  final String title;
  final List<HelpEntry> entries;
}

class HelpEntry {
  const HelpEntry(this.subtitle, this.body);

  final String subtitle;
  final String body;
}

/// Returns the full manual content for the given [language].
List<HelpSection> helpSectionsFor(AppLanguage language) {
  final isGerman = language == AppLanguage.german;
  return isGerman ? _germanSections : _englishSections;
}

final List<HelpSection> _germanSections = [
  HelpSection(
    icon: Icons.table_restaurant,
    title: 'Tische verwalten',
    entries: const [
      HelpEntry(
        'Tisch erstellen',
        'Klicke auf einen der Tisch-Buttons (2er ⇆, 1er, 2er ⇵). Der Tisch erscheint automatisch an einer freien Position.',
      ),
      HelpEntry(
        'Tisch verschieben',
        'Ziehe den Tisch mit gedrückter linker Maustaste. Er rastet automatisch ins Raster ein.',
      ),
      HelpEntry(
        'Tisch löschen',
        '• Ziehe den Tisch zum Mülleimer (unten rechts)\n• Halte den Tisch lange gedrückt\n• Nutze "Alle löschen" für alle Tische',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.people,
    title: 'Namensliste verwalten',
    entries: const [
      HelpEntry(
        'Namen hinzufügen',
        '1. Klicke auf "Namensliste"\n2. Gib einen Namen ein\n3. Drücke Enter oder "Hinzufügen"\n4. Speichere mit dem Speicherkarten-Symbol',
      ),
      HelpEntry(
        'Namen entfernen',
        '1. Öffne die "Namensliste"\n2. Klicke auf das Mülleimer-Symbol beim Namen\n3. Speichere die Änderungen',
      ),
      HelpEntry(
        'Platz Konfiguration',
        '1. Öffne die "Namensliste"\n2. Klicke auf das Zahnrad-Symbol beim Namen\n3. Wähle einen Platz, oder wähle eine Reihe durch die Check-Boxen links.',
      ),
      HelpEntry(
        'Konfiguration entfernen',
        '1. Öffne die "Namensliste"\n2. Klicke auf das rote X',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.block,
    title: 'Tabu-Liste (Sitzverbote)',
    entries: const [
      HelpEntry(
        'Tabu-Paar hinzufügen',
        'Voraussetzung: Mindestens 2 Namen in der Liste\n\n1. Klicke auf "Paare"\n2. Wähle zwei Schüler aus den Dropdown-Menüs\n3. Klicke "Tabu-Paar hinzufügen"\n4. Speichere mit dem Speicherkarten-Symbol',
      ),
      HelpEntry(
        'Tabu-Paar entfernen',
        '1. Öffne die "Paare"\n2. Klicke auf das Mülleimer-Symbol beim Paar\n3. Speichere die Änderungen',
      ),
      HelpEntry(
        'ℹ️ Hinweis',
        'Tabu-Paare dürfen nicht am selben Tisch oder an direkt benachbarten Tischen sitzen (außer ein anderer Tisch ist dazwischen).',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.favorite,
    title: 'Favoriten-Liste',
    entries: const [
      HelpEntry(
        'Favoriten-Paar hinzufügen',
        'Voraussetzung: Mindestens 2 Namen in der Liste\n\n1. Klicke auf "Paare"\n2. Lege den Regler rechts oben von "Tabu" auf "Favorit" um\n3. Wähle zwei Schüler aus den Dropdown-Menüs\n4. Klicke "Favoriten-Paar hinzufügen"\n5. Speichere mit dem Speicherkarten-Symbol',
      ),
      HelpEntry(
        'Favoriten-Paar entfernen',
        '1. Öffne "Paare"\n2. Klicke auf das Mülleimer-Symbol beim Paar\n3. Speichere die Änderungen',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.shuffle,
    title: 'Sitzordnung erstellen',
    entries: const [
      HelpEntry(
        'Randomizer starten',
        'Klicke auf den grünen "Randomizer"-Button. Das Programm verteilt alle Schüler automatisch unter Beachtung der Tabu-Liste.',
      ),
      HelpEntry(
        '⚠️ Fehlermeldungen',
        '• Zu viele Schüler: Füge mehr Tische hinzu\n• Keine gültige Sitzordnung: Reduziere Tabu-Paare oder füge mehr Tische hinzu',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.swap_horiz,
    title: 'Tausch-Modus',
    entries: const [
      HelpEntry(
        'Verwendung',
        'Klicke auf den violetten "Tausch-Modus"-Button. Klicke nun 2 Schüler an, die getauscht werden sollen.\nNach Abschluss des Tauschs klicke auf den nun orangenen "Tausch beenden"-Button.',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.print,
    title: 'Sitzordnung drucken',
    entries: const [
      HelpEntry(
        'Drucken starten',
        'Klicke auf den blauen "Drucken"-Button. Es öffnet sich der Druck-Dialog. Wähle deinen Drucker und bestätige mit "Drucken".',
      ),
      HelpEntry(
        '⚙️ Einstellen',
        '• Drucker auswählen\n• Farbig oder Schwarz-Weiß\n• Nach Bedarf skalieren',
      ),
      HelpEntry(
        '⚠️ Fehlermeldung',
        '• Keine Tische zum Drucken vorhanden: Füge Tische hinzu',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.table_restaurant_rounded,
    title: 'Klassen',
    entries: const [
      HelpEntry(
        'Klasse erstellen',
        '1. Gib den Namen ein\n2. Drücke Enter oder "Hinzufügen"',
      ),
      HelpEntry(
        'Handlungsmöglichkeiten',
        '• Öffnen: Klick auf die Box\n• Umbenennen: 3 Punkte -> "Umbenennen" -> Name eingeben -> Fertig\n• Löschen: 3 Punkte -> "Löschen"\n• Verschieben: Mit gedrückter Maustaste ziehen & loslassen.',
      ),
      HelpEntry(
        'Klasse wechseln',
        'Rechts oben auf das Wechsel-Symbol klicken -> Klasse auswählen.',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.settings,
    title: 'Einstellungen',
    entries: const [
      HelpEntry(
        'Klassenname anzeigen',
        'In den Einstellungen aktivierbar. Der Klassenname wird oben links angezeigt, auch beim Drucken.\n⚠️ Achtung: Die Anzeige kann Tische überdecken!',
      ),
      HelpEntry(
        'Mülleimer AUS/AN',
        'In den Einstellungen aktivierbar. Ist der Mülleimer deaktiviert, können Tische dort platziert werden, ohne gelöscht zu werden. Löschen ist dann nur noch durch langes Gedrückthalten möglich.',
      ),
      HelpEntry(
        'Raster AUS/AN',
        'In den Einstellungen aktivierbar. Ist das Raster ausgeblendet, rasten Tische trotzdem weiterhin ein.',
      ),
      HelpEntry(
        'Sprache',
        'In den Einstellungen zwischen Deutsch und Englisch wechseln.',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.lightbulb_outline,
    title: 'Tipps & Tricks',
    entries: const [
      HelpEntry(
        'Statistikleiste',
        'Oben siehst du: Anzahl Schüler, Tische, verfügbare Plätze, Tabu- und Favoriten-Paare.',
      ),
      HelpEntry(
        'Arbeitsfläche',
        'Die weiße Fläche entspricht einem DIN A4 Blatt im Querformat. Tische rasten automatisch ins Raster ein.',
      ),
      HelpEntry(
        'Daten speichern',
        'Alle Änderungen werden automatisch gespeichert (außer in den Editoren - dort das Speicherkarten-Symbol klicken!).',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.build,
    title: 'Credits',
    entries: const [HelpEntry('Developed by', 'zJeremi3')],
  ),
];

final List<HelpSection> _englishSections = [
  HelpSection(
    icon: Icons.table_restaurant,
    title: 'Managing desks',
    entries: const [
      HelpEntry(
        'Create a desk',
        'Tap one of the desk buttons (2-seat ⇆, 1-seat, 2-seat ⇵). The desk appears automatically at a free spot.',
      ),
      HelpEntry(
        'Move a desk',
        'Drag the desk with the mouse (or your finger). It snaps to the grid automatically.',
      ),
      HelpEntry(
        'Delete a desk',
        '• Drag the desk onto the trash can (bottom right)\n• Long-press the desk\n• Use "Delete all" to remove every desk',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.people,
    title: 'Managing the student list',
    entries: const [
      HelpEntry(
        'Add a student',
        '1. Open "Student list"\n2. Type a name\n3. Press Enter or "Add"\n4. Save with the save icon',
      ),
      HelpEntry(
        'Remove a student',
        '1. Open the "Student list"\n2. Tap the trash icon next to the name\n3. Save your changes',
      ),
      HelpEntry(
        'Configure a seat',
        '1. Open the "Student list"\n2. Tap the gear icon next to the name\n3. Choose a seat, or a row via the checkboxes on the left.',
      ),
      HelpEntry(
        'Remove a seat rule',
        '1. Open the "Student list"\n2. Tap the red X',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.block,
    title: 'Taboo list (seating bans)',
    entries: const [
      HelpEntry(
        'Add a taboo pair',
        'Requires at least 2 names in the list.\n\n1. Tap "Pairs"\n2. Choose two students from the dropdowns\n3. Tap "Add taboo pair"\n4. Save with the save icon',
      ),
      HelpEntry(
        'Remove a taboo pair',
        '1. Open "Pairs"\n2. Tap the trash icon next to the pair\n3. Save your changes',
      ),
      HelpEntry(
        'ℹ️ Note',
        'Taboo pairs may not sit at the same desk or at directly neighbouring desks (unless another desk is in between).',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.favorite,
    title: 'Favorite list',
    entries: const [
      HelpEntry(
        'Add a favorite pair',
        'Requires at least 2 names in the list.\n\n1. Tap "Pairs"\n2. Flip the switch top right from "Taboo" to "Favorite"\n3. Choose two students from the dropdowns\n4. Tap "Add favorite pair"\n5. Save with the save icon',
      ),
      HelpEntry(
        'Remove a favorite pair',
        '1. Open "Pairs"\n2. Tap the trash icon next to the pair\n3. Save your changes',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.shuffle,
    title: 'Creating a seating plan',
    entries: const [
      HelpEntry(
        'Start the randomizer',
        'Tap the green "Randomizer" button. The app distributes all students automatically while respecting the taboo list.',
      ),
      HelpEntry(
        '⚠️ Error messages',
        '• Too many students: add more desks\n• No valid seating plan: reduce taboo pairs or add more desks',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.swap_horiz,
    title: 'Swap mode',
    entries: const [
      HelpEntry(
        'How to use it',
        'Tap the purple "Swap mode" button, then tap the two students you want to swap.\nWhen you are done, tap the now-orange "End swap" button.',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.print,
    title: 'Printing the seating plan',
    entries: const [
      HelpEntry(
        'Start printing',
        'Tap the blue "Print" button. The print dialog opens - choose your printer and confirm with "Print".',
      ),
      HelpEntry(
        '⚙️ Options',
        '• Choose a printer\n• Color or black & white\n• Scale as needed',
      ),
      HelpEntry(
        '⚠️ Error message',
        '• No desks to print: add some desks first',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.table_restaurant_rounded,
    title: 'Classes',
    entries: const [
      HelpEntry('Create a class', '1. Type the name\n2. Press Enter or "Add"'),
      HelpEntry(
        'What you can do',
        '• Open: tap the box\n• Rename: 3 dots -> "Rename" -> type name -> done\n• Delete: 3 dots -> "Delete"\n• Reorder: drag and drop with the mouse held down.',
      ),
      HelpEntry(
        'Switch class',
        'Tap the switch icon in the top right, then choose a class.',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.settings,
    title: 'Settings',
    entries: const [
      HelpEntry(
        'Show class name',
        'Can be enabled in Settings. The class name is shown in the top-left corner, also on printouts.\n⚠️ Warning: the label can cover desks!',
      ),
      HelpEntry(
        'Trash can on/off',
        'Can be toggled in Settings. With the trash can disabled, desks can be placed there without being deleted. Deleting a desk then requires a long press.',
      ),
      HelpEntry(
        'Grid on/off',
        'Can be toggled in Settings. Desks still snap to the grid even while it is hidden.',
      ),
      HelpEntry('Language', 'Switch between German and English in Settings.'),
    ],
  ),
  HelpSection(
    icon: Icons.lightbulb_outline,
    title: 'Tips & tricks',
    entries: const [
      HelpEntry(
        'Statistics bar',
        'At the top you see: number of students, desks, available seats, taboo and favorite pairs.',
      ),
      HelpEntry(
        'Canvas',
        'The white area corresponds to a landscape A4 sheet. Desks snap to the grid automatically.',
      ),
      HelpEntry(
        'Saving data',
        'All changes are saved automatically (except inside the editors - tap the save icon there!).',
      ),
    ],
  ),
  HelpSection(
    icon: Icons.build,
    title: 'Credits',
    entries: const [HelpEntry('Developed by', 'zJeremi3')],
  ),
];
