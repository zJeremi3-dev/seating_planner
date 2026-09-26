# Seating Plan Randomizer

![CI](https://github.com/zJeremi3-dev/seating_planner/actions/workflows/ci.yml/badge.svg)

A local-first Flutter desktop app that generates seating plans for school classes — desks, students, "must not sit together" / "should sit together" rules, fixed seats, and a randomizer that respects all of them. Everything runs and is stored entirely on-device, in German or English.

Originally built as a practical tool for a teacher; rebuilt from a single 3000-line file into a properly layered, unit-testable app.

## Features

- Drag & drop desk layout on a DIN A4-shaped canvas (1-seat and 2-seat desks, horizontal or vertical)
- Student list with per-student **fixed seats** (pin a student to specific seats and/or whole rows)
- **Taboo pairs** (must not sit next to each other) and **favorite pairs** (should share a desk)
- One-click **randomizer** that satisfies fixed seats, favorites and taboo rules (backtracking with a bounded number of attempts)
- **Swap mode** to manually exchange two students after generating a plan
- Multiple classes, each with its own desks/students/rules, reorderable and renameable
- PDF export / printing of the current plan
- Settings: language (German/English), trash-can/grid/class-label toggles
- Fully responsive: the whole board (grid, desks, trash can, class label) scales together to fit any window size

## Tech stack

- **Flutter** — UI framework
- **Riverpod** — state management (`ChangeNotifierProvider` wrapping plain `ChangeNotifier` controllers)
- **shared_preferences** — local persistence
- **pdf** / **printing** — PDF export
- **reorderable_grid_view** — drag-to-reorder class list

## Architecture

```
lib/
  models/      Pure data classes (SeatTable, FixedSeat, TabooPair, FavoritePair, SchoolClass)
  data/        Static config (AppConfig) + persistence (DataManager) + PDF export
  l10n/        AppStrings (DE/EN), help/manual content, controller-message translation
  state/       SeatingController, ClassesController, SettingsController (all UI-independent) + Riverpod providers
  widgets/     Reusable, dumb UI pieces (TableWidget, GridPainter, TrashCan)
  app/         Screen composition (HomePage, button bar, stats bar, canvas, help dialog)
  settings/    Settings dialog
  modules/     Student-list editor, pair editor, seat-selection dialog, class editor
```

The guiding principle: each layer has exactly one reason to change. `SeatingController` (desks/students/rules/randomizer) and `ClassesController`/`SettingsController` know nothing about `BuildContext` or any Flutter widget — user feedback is reported as plain string codes via a callback and turned into localized `SnackBar` text by the UI layer (`l10n/message_resolver.dart`). This is what makes the logic directly unit-testable without spinning up any UI. Riverpod's `ChangeNotifierProvider` exposes the controllers to the widget tree without manual prop-drilling.

## Getting started

```
flutter pub get
flutter run
```

## Testing

```
flutter analyze
flutter test
```

Not yet implemented — see [Known limitations](#known-limitations--roadmap).

## Known limitations / roadmap

- **Unit tests** for `SeatingController` (randomizer correctness, taboo/favorite/fixed-seat logic, row detection), persistence round-trips for `DataManager`, and widget tests for the editors.
- **Dark mode is not implemented.** The Settings dialog already shows a disabled placeholder switch for it; it's intentionally deferred to a later commit rather than rushed in.
- Class/desk geometry (grid size, desk sizes, neighbor thresholds) lives in `AppConfig` as fixed pixel constants, matching the original design; the whole board is scaled as one unit via `FittedBox` rather than each element scaling independently.

## Licenses

This app bundles a few open-source packages (Riverpod, pdf, printing, shared_preferences, reorderable_grid_view), each under its own permissive license (MIT/BSD/Apache-2.0). See each package's page on [pub.dev](https://pub.dev) for details.