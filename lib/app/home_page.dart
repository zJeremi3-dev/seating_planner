import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pdf_export.dart';
import '../l10n/message_resolver.dart';
import '../modules/class_editor.dart';
import '../modules/name_editor.dart';
import '../modules/pair_editor.dart';
import '../settings/settings_dialog.dart';
import '../state/providers.dart';
import '../widgets/text_measure.dart';
import 'bottom_bar.dart';
import 'button_bar.dart';
import 'seating_canvas.dart';
import 'statistics_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  /// Sentinel so the very first build (before any class is loaded) also
  /// triggers a sync; a real class id or `null` are both valid "handled"
  /// values, so a separate flag is used instead of reusing those.
  Object? _lastHandledClassId = _unset;
  static const _unset = Object();

  @override
  void initState() {
    super.initState();
    // The controller has no BuildContext of its own, so it reports events
    // as plain string codes and the UI (here) turns them into a SnackBar.
    ref.read(seatingControllerProvider).onMessage = _showMessage;
  }

  void _showMessage(String code) {
    if (!mounted) return;
    final strings = ref.read(appStringsProvider);
    final text = resolveControllerMessage(code, strings);
    _showSnackBar(text);
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: 8,
            left: 8,
            right:
                MediaQuery.of(context).size.width -
                measureTextWidth(text, 14) -
                30,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  Future<void> _openNameEditor() async {
    final strings = ref.read(appStringsProvider);
    final seating = ref.read(seatingControllerProvider);
    if (seating.classId == null) return;

    final result = await Navigator.push<NameListEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => NameEditor(
          strings: strings,
          students: seating.students,
          fixedSeats: seating.fixedSeats,
          tables: seating.tables,
          rows: seating.detectRowGroups(),
          rowKeyFn: seating.rowKey,
          canvasWidth: seating.canvasWidth,
          canvasHeight: seating.canvasHeight,
        ),
      ),
    );
    if (result != null) {
      await seating.applyStudentListEdit(result.students, result.fixedSeats);
    }
  }

  Future<void> _openPairEditor() async {
    final strings = ref.read(appStringsProvider);
    final seating = ref.read(seatingControllerProvider);
    if (seating.classId == null) return;
    if (seating.students.length < 2) {
      _showSnackBar(strings.pleaseAddStudentsMsg);
      return;
    }

    final result = await Navigator.push<PairEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PairEditor(
          strings: strings,
          tabooPairs: List.from(seating.tabooPairs),
          favoritePairs: List.from(seating.favoritePairs),
          availableStudents: seating.students,
        ),
      ),
    );
    if (result != null) {
      await seating.applyPairEdit(result.tabooPairs, result.favoritePairs);
    }
  }

  Future<void> _print() async {
    final strings = ref.read(appStringsProvider);
    final seating = ref.read(seatingControllerProvider);
    final settings = ref.read(settingsControllerProvider);
    final classesController = ref.read(classesControllerProvider);
    if (seating.tables.isEmpty) {
      _showSnackBar(strings.noTablesToPrintMsg);
      return;
    }
    final className = classesController.classes
        .firstWhere(
          (c) => c.id == seating.classId,
          orElse: () => classesController.classes.first,
        )
        .name;
    await exportSeatingPlanPdf(
      tables: seating.tables,
      canvasWidth: seating.canvasWidth,
      canvasHeight: seating.canvasHeight,
      showClassLabel: settings.displaySettings.classLabelVisible,
      className: className,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final classesController = ref.watch(classesControllerProvider);
    final seating = ref.watch(seatingControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final selectedClassId = classesController.selectedClassId;

    // Keep the seating board in sync with whichever class is selected.
    // ChangeNotifierProvider always exposes the same instance, so we track
    // the last id we reacted to ourselves instead of relying on
    // before/after values from Riverpod.
    if (!classesController.isLoading &&
        selectedClassId != _lastHandledClassId) {
      _lastHandledClassId = selectedClassId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedClassId != null) {
          seating.loadForClass(selectedClassId);
        } else {
          seating.clear();
        }
      });
    }

    final showBoard =
        selectedClassId != null && seating.classId == selectedClassId;
    String? selectedClassName;
    if (selectedClassId != null) {
      final match = classesController.classes.where(
        (c) => c.id == selectedClassId,
      );
      selectedClassName = match.isNotEmpty ? match.first.name : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(strings.appTitle),
            if (selectedClassName != null) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.class_, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      selectedClassName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (selectedClassId != null)
            IconButton(
              icon: const Icon(Icons.switch_account),
              tooltip: strings.switchClassTooltip,
              onPressed: classesController.goToClassOverview,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: strings.settingsTooltip,
            onPressed: () => showSettingsDialog(context),
          ),
        ],
      ),
      body: selectedClassId == null
          ? ClassEditor(strings: strings)
          : !showBoard
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SeatingButtonBar(
                  strings: strings,
                  swapModeActive: seating.swapModeActive,
                  onAddTable2Horizontal: () =>
                      seating.addTable(2, 'horizontal'),
                  onAddTable1: () => seating.addTable(1, 'horizontal'),
                  onAddTable2Vertical: () => seating.addTable(2, 'vertical'),
                  onOpenNameList: _openNameEditor,
                  onOpenPairs: _openPairEditor,
                  onRunRandomizer: seating.runRandomizer,
                  onToggleSwapMode: seating.toggleSwapMode,
                  onDeleteAllTables: seating.deleteAllTables,
                ),
                const Divider(),
                StatisticsBar(
                  strings: strings,
                  studentCount: seating.students.length,
                  tableCount: seating.tables.length,
                  seatCount: seating.totalSeats,
                  tabooCount: seating.tabooPairs.length,
                  favoriteCount: seating.favoritePairs.length,
                  fixedSeatCount: seating.fixedSeats
                      .where((f) => f.hasFixedSeat)
                      .length,
                  swapModeActive: seating.swapModeActive,
                  swapModeWaitingForSecondPick:
                      seating.firstSwapPickTableId != null,
                ),
                const Divider(),
                Expanded(
                  child: FittedBox(
                    child: SizedBox(
                      width: 965,
                      height: 685,
                      child: seating.tables.isEmpty
                          ? Center(
                              child: Text(
                                strings.noTablesHint,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SeatingCanvas(
                              strings: strings,
                              className: selectedClassName ?? '',
                              onTableDeleted: (seatCount) => _showSnackBar(
                                strings.tableDeletedMsg(seatCount),
                              ),
                            ),
                    ),
                  ),
                ),
                const Divider(),
                SeatingBottomBar(
                  strings: strings,
                  classLabelVisible: settings.displaySettings.classLabelVisible,
                  trashCanEnabled: settings.displaySettings.trashCanEnabled,
                  gridVisible: settings.displaySettings.gridVisible,
                  onClassLabelChanged: settings.setClassLabelVisible,
                  onTrashCanChanged: settings.setTrashCanEnabled,
                  onGridChanged: settings.setGridVisible,
                  onPrint: _print,
                ),
              ],
            ),
    );
  }
}
