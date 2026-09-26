import 'dart:math';
import 'dart:ui' show Offset, Size;

import 'package:flutter/foundation.dart';

import '../data/app_config.dart';
import '../data/data_manager.dart';
import '../models/favorite_pair.dart';
import '../models/fixed_seat.dart';
import '../models/seat_table.dart';
import '../models/taboo_pair.dart';

/// Holds and manipulates everything that belongs to one open class:
/// its desks, its students, its taboo/favorite pairs, its fixed-seat
/// rules, and the randomizer that arranges students on the desks.
///
/// This class has no dependency on [BuildContext] or any other Flutter
/// widget - user-facing feedback is reported through [onMessage] instead
/// of showing a `SnackBar` directly, which keeps it plain-Dart testable.
class SeatingController extends ChangeNotifier {
  SeatingController({this.onMessage});

  /// Called whenever the controller wants to show a short status message
  /// to the user (success/error feedback). The UI layer wires this up to
  /// a `SnackBar`.
  void Function(String message)? onMessage;

  String? _classId;
  String? get classId => _classId;

  List<SeatTable> tables = [];
  List<String> students = [];
  List<TabooPair> tabooPairs = [];
  List<FavoritePair> favoritePairs = [];
  List<FixedSeat> fixedSeats = [];

  int _tableCounter = 0;
  String? draggedTableId;

  double canvasWidth = 800;
  double canvasHeight = 566;

  bool swapModeActive = false;
  String? _swapTableId1;
  int? _swapSeatIndex1;

  bool get isLoaded => _classId != null;
  int get totalSeats => tables.fold<int>(0, (sum, t) => sum + t.seatCount);
  bool get hasAnyFixedSeat => fixedSeats.any(
    (f) => f.allowedSeats.isNotEmpty || f.allowedRowIds.isNotEmpty,
  );
  String? get firstSwapPickTableId => _swapTableId1;
  int? get firstSwapPickSeatIndex => _swapSeatIndex1;

  void _notify(String message) => onMessage?.call(message);

  // Loading / class switching -----------------------------------------------

  Future<void> loadForClass(String classId) async {
    _classId = classId;
    tables = await DataManager.loadTables(classId);
    students = await DataManager.loadStudents(classId);
    tabooPairs = await DataManager.loadTabooPairs(classId);
    favoritePairs = await DataManager.loadFavoritePairs(classId);
    fixedSeats = await DataManager.loadFixedSeats(classId);

    // Every student needs exactly one FixedSeat entry; drop stale ones.
    for (final name in students) {
      if (!fixedSeats.any((f) => f.studentName == name)) {
        fixedSeats.add(FixedSeat(studentName: name));
      }
    }
    fixedSeats.removeWhere((f) => !students.contains(f.studentName));
    _cleanupFixedSeatReferences();

    _tableCounter = tables.isEmpty
        ? 0
        : tables
                  .map((t) => int.parse(t.id.split('_')[1]))
                  .reduce((a, b) => a > b ? a : b) +
              1;

    notifyListeners();
  }

  void clear() {
    _classId = null;
    tables = [];
    students = [];
    tabooPairs = [];
    favoritePairs = [];
    fixedSeats = [];
    _tableCounter = 0;
    notifyListeners();
  }

  Future<void> _persistTables() async {
    if (_classId != null) await DataManager.saveTables(tables, _classId!);
  }

  Future<void> _persistFixedSeats() async {
    if (_classId != null) {
      await DataManager.saveFixedSeats(fixedSeats, _classId!);
    }
  }

  // Desk management ---------------------------------------------------------

  Future<void> addTable(int seatCount, String direction) async {
    if (_classId == null) return;
    final position = _findFreeSpot(seatCount, direction);
    if (position == null) {
      _notify('no_free_spot');
      return;
    }
    tables.add(
      SeatTable(
        id: 'table_${_tableCounter++}',
        seatCount: seatCount,
        position: position,
        direction: direction,
      ),
    );
    notifyListeners();
    await _persistTables();
  }

  Offset? _findFreeSpot(int seatCount, String direction) {
    final tableWidth = AppConfig.tableWidth(seatCount, direction);
    final tableHeight = AppConfig.tableHeight(seatCount, direction);
    final maxX = AppConfig.maxGridX * AppConfig.gridSize;
    final maxY = AppConfig.maxGridY * AppConfig.gridSize;
    final random = Random();

    for (int attempt = 0; attempt < 100; attempt++) {
      final x =
          random.nextDouble() *
          min(canvasWidth - tableWidth, maxX - tableWidth);
      final y =
          random.nextDouble() *
          min(canvasHeight - tableHeight, maxY - tableHeight);
      final position = snapToGrid(Offset(x, y));
      final probe = SeatTable(
        id: 'temp',
        seatCount: seatCount,
        position: position,
      );
      if (!wouldOverlap(probe, position, direction)) return position;
    }
    return null;
  }

  Future<void> deleteTable(String id) async {
    if (_classId == null) return;
    tables.removeWhere((t) => t.id == id);
    _cleanupFixedSeatReferences();
    notifyListeners();
    await _persistTables();
    await _persistFixedSeats();
  }

  Future<void> deleteAllTables() async {
    if (_classId == null) return;
    tables.clear();
    _tableCounter = 0;
    _cleanupFixedSeatReferences();
    notifyListeners();
    await _persistTables();
    await _persistFixedSeats();
    _notify('all_tables_deleted');
  }

  /// Drops fixed-seat / fixed-row references that point at desks which no
  /// longer exist.
  void _cleanupFixedSeatReferences() {
    final tableIds = tables.map((t) => t.id).toSet();
    for (final f in fixedSeats) {
      f.allowedSeats.removeWhere((p) => !tableIds.contains(p['tableId']));
      f.allowedRowIds.removeWhere(
        (rowId) => rowId.split(',').any((id) => !tableIds.contains(id)),
      );
    }
  }

  // Position / collision helpers ---------------------------------------------

  Offset snapToGrid(Offset position) {
    final maxX = AppConfig.maxGridX * AppConfig.gridSize;
    final maxY = AppConfig.maxGridY * AppConfig.gridSize;
    final clampedX = position.dx.clamp(0.0, maxX);
    final clampedY = position.dy.clamp(0.0, maxY);
    return Offset(
      (clampedX / AppConfig.gridSize).round() * AppConfig.gridSize,
      (clampedY / AppConfig.gridSize).round() * AppConfig.gridSize,
    );
  }

  bool wouldOverlap(SeatTable table, Offset newPosition, [String? direction]) {
    final dir = direction ?? table.direction;
    final newWidth = AppConfig.tableWidth(table.seatCount, dir);
    final newHeight = AppConfig.tableHeight(table.seatCount, dir);

    for (final other in tables) {
      if (other.id == table.id) continue;
      final otherWidth = AppConfig.tableWidth(other.seatCount, other.direction);
      final otherHeight = AppConfig.tableHeight(
        other.seatCount,
        other.direction,
      );
      final overlaps =
          !(newPosition.dx + newWidth + AppConfig.tableBuffer <
                  other.position.dx ||
              newPosition.dx >
                  other.position.dx + otherWidth + AppConfig.tableBuffer ||
              newPosition.dy + newHeight + AppConfig.tableBuffer <
                  other.position.dy ||
              newPosition.dy >
                  other.position.dy + otherHeight + AppConfig.tableBuffer);
      if (overlaps) return true;
    }
    return false;
  }

  bool isOverTrashCan(
    Offset position,
    Size canvasSize,
    SeatTable table, {
    required bool trashCanEnabled,
  }) {
    if (!trashCanEnabled) return false;
    final trashX =
        canvasSize.width - AppConfig.trashCanSize - AppConfig.trashCanMargin;
    final trashY =
        canvasSize.height - AppConfig.trashCanSize - AppConfig.trashCanMargin;
    final tableWidth = AppConfig.tableWidth(table.seatCount, table.direction);
    final tableHeight = AppConfig.tableHeight(table.seatCount, table.direction);
    final centerX = position.dx + tableWidth / 2;
    final centerY = position.dy + tableHeight / 2;
    return centerX >= trashX &&
        centerX <= trashX + AppConfig.trashCanSize &&
        centerY >= trashY &&
        centerY <= trashY + AppConfig.trashCanSize;
  }

  /// Persists the current desk positions, e.g. after a drag ends.
  Future<void> persistTables() => _persistTables();

  void setDraggedTable(String? tableId) {
    draggedTableId = tableId;
    notifyListeners();
  }

  void moveTable(SeatTable table, Offset newPosition) {
    table.position = newPosition;
    notifyListeners();
  }

  // Row detection -------------------------------------------------------

  /// Groups of directly adjacent desks (2 or more) - a "row".
  List<List<String>> detectRowGroups() {
    final parent = <String, String>{for (final t in tables) t.id: t.id};

    String find(String x) {
      if (parent[x] != x) parent[x] = find(parent[x]!);
      return parent[x]!;
    }

    void union(String a, String b) {
      final ra = find(a);
      final rb = find(b);
      if (ra != rb) parent[ra] = rb;
    }

    for (int i = 0; i < tables.length; i++) {
      for (int j = i + 1; j < tables.length; j++) {
        if (_areTablesNeighbors(tables[i], tables[j])) {
          union(tables[i].id, tables[j].id);
        }
      }
    }

    final groups = <String, List<String>>{};
    for (final t in tables) {
      groups.putIfAbsent(find(t.id), () => []).add(t.id);
    }
    return groups.values.where((g) => g.length >= 2).toList();
  }

  bool _areTablesNeighbors(SeatTable t1, SeatTable t2) {
    final t1w = AppConfig.tableWidth(t1.seatCount, t1.direction);
    final t1h = AppConfig.tableHeight(t1.seatCount, t1.direction);
    final t2w = AppConfig.tableWidth(t2.seatCount, t2.direction);
    final t2h = AppConfig.tableHeight(t2.seatCount, t2.direction);
    final t1L = t1.position.dx, t1R = t1L + t1w;
    final t1T = t1.position.dy, t1B = t1T + t1h;
    final t2L = t2.position.dx, t2R = t2L + t2w;
    final t2T = t2.position.dy, t2B = t2T + t2h;

    final verticalOverlap = !(t1B < t2T || t1T > t2B);
    if (verticalOverlap) {
      final hDist = t1R < t2L ? t2L - t1R : (t1L > t2R ? t1L - t2R : 0.0);
      if (hDist < AppConfig.neighborThreshold) return true;
    }
    final horizontalOverlap = !(t1R < t2L || t1L > t2R);
    if (horizontalOverlap) {
      final vDist = t1B < t2T ? t2T - t1B : (t1T > t2B ? t1T - t2B : 0.0);
      if (vDist < AppConfig.neighborThreshold) return true;
    }
    return false;
  }

  /// Stable, order-independent key identifying a row (sorted, comma-joined
  /// desk ids). Used to reference the same row across sessions.
  String rowKey(List<String> rowTableIds) {
    final sorted = List<String>.from(rowTableIds)..sort();
    return sorted.join(',');
  }

  // Swap mode -----------------------------------------------------------

  void toggleSwapMode() {
    swapModeActive = !swapModeActive;
    _swapTableId1 = null;
    _swapSeatIndex1 = null;
    notifyListeners();
    if (swapModeActive) _notify('swap_mode_started');
  }

  void handleSeatTapForSwap(String tableId, int seatIndex) {
    final table = tables.firstWhere((t) => t.id == tableId);
    final student = table.students[seatIndex];

    if (_swapTableId1 == null) {
      _swapTableId1 = tableId;
      _swapSeatIndex1 = seatIndex;
      notifyListeners();
      _notify(
        student == null
            ? 'swap_first_picked_empty'
            : 'swap_first_picked:$student',
      );
      return;
    }

    if (_swapTableId1 == tableId && _swapSeatIndex1 == seatIndex) {
      _swapTableId1 = null;
      _swapSeatIndex1 = null;
      notifyListeners();
      _notify('swap_selection_cleared');
      return;
    }

    final table1 = tables.firstWhere((t) => t.id == _swapTableId1!);
    final table2 = tables.firstWhere((t) => t.id == tableId);
    final temp = table1.students[_swapSeatIndex1!];
    table1.students[_swapSeatIndex1!] = table2.students[seatIndex];
    table2.students[seatIndex] = temp;
    _swapTableId1 = null;
    _swapSeatIndex1 = null;
    notifyListeners();
    _persistTables();
    _notify('swap_done');
  }

  // Randomizer -----------------------------------------------------------

  Future<void> runRandomizer() async {
    if (_classId == null) return;
    if (students.isEmpty) {
      _notify('no_students');
      return;
    }
    if (tables.isEmpty) {
      _notify('no_tables');
      return;
    }
    if (students.length > totalSeats) {
      _notify('too_many_students:${students.length}:$totalSeats');
      return;
    }

    bool success = false;
    int attempts = 0;
    while (!success && attempts < AppConfig.maxAttempts) {
      success = _attemptSeating();
      attempts++;
    }

    if (success) {
      notifyListeners();
      await _persistTables();
      _notify('seating_created');
    } else {
      _notify('no_valid_seating');
    }
  }

  bool _attemptSeating() {
    for (final table in tables) {
      table.students = List.filled(table.seatCount, null);
    }

    final rows = detectRowGroups();
    final random = Random();

    // Phase 1: students pinned to specific seats.
    for (final f in fixedSeats) {
      if (f.allowedSeats.isEmpty) continue;
      final available = f.allowedSeats.where((p) {
        final matches = tables.where((t) => t.id == p['tableId']);
        if (matches.isEmpty) return false;
        final table = matches.first;
        final seatIndex = p['seatIndex'] as int;
        return seatIndex < table.seatCount && table.students[seatIndex] == null;
      }).toList();
      if (available.isEmpty) return false;
      available.shuffle(random);
      final chosen = available.first;
      final table = tables.firstWhere((t) => t.id == chosen['tableId']);
      table.students[chosen['seatIndex'] as int] = f.studentName;
    }

    // Phase 2: students pinned to one of several allowed rows.
    for (final f in fixedSeats) {
      if (f.allowedSeats.isNotEmpty) continue;
      if (f.allowedRowIds.isEmpty) continue;
      final options = <MapEntry<String, int>>[];
      for (final rowId in f.allowedRowIds) {
        List<String>? matchingRow;
        for (final row in rows) {
          if (rowKey(row) == rowId) {
            matchingRow = row;
            break;
          }
        }
        if (matchingRow == null) continue;
        for (final tableId in matchingRow) {
          final table = tables.firstWhere((t) => t.id == tableId);
          for (int i = 0; i < table.seatCount; i++) {
            if (table.students[i] == null) options.add(MapEntry(tableId, i));
          }
        }
      }
      if (options.isEmpty) return false;
      options.shuffle(random);
      final chosen = options.first;
      tables.firstWhere((t) => t.id == chosen.key).students[chosen.value] =
          f.studentName;
    }

    // Phase 3: distribute the remaining students randomly.
    final pinned = fixedSeats
        .where((f) => f.allowedSeats.isNotEmpty || f.allowedRowIds.isNotEmpty)
        .map((f) => f.studentName)
        .toSet();
    final shuffledStudents = List<String>.from(
      students.where((n) => !pinned.contains(n)),
    )..shuffle(random);
    final shuffledTables = List<SeatTable>.from(tables)..shuffle(random);

    int studentIndex = 0;
    for (final table in shuffledTables) {
      if (studentIndex < shuffledStudents.length) {
        final randomSeat = random.nextInt(table.seatCount);
        if (table.students[randomSeat] == null) {
          table.students[randomSeat] = shuffledStudents[studentIndex];
          studentIndex++;
        }
      }
    }
    for (final table in shuffledTables) {
      final seatIndices = List.generate(table.seatCount, (i) => i)
        ..shuffle(random);
      for (final seatIndex in seatIndices) {
        if (table.students[seatIndex] != null) continue;
        if (studentIndex < shuffledStudents.length) {
          table.students[seatIndex] = shuffledStudents[studentIndex];
          studentIndex++;
        }
      }
    }

    // Favorite-pair check: main student must share a desk with one
    // available "sec" student, if any of them made it onto the plan.
    for (final favorite in favoritePairs) {
      String? mainTableId;
      for (final table in tables) {
        for (int i = 0; i < table.seatCount; i++) {
          if (table.students[i] == favorite.mainStudent) mainTableId = table.id;
        }
      }
      if (mainTableId == null) continue;

      final availableSecs = favorite.secondaryStudents.where((sec) {
        for (final table in tables) {
          for (int i = 0; i < table.seatCount; i++) {
            if (table.students[i] == sec) return true;
          }
        }
        return false;
      }).toList();
      if (availableSecs.isEmpty) continue;

      final chosenSec = availableSecs[random.nextInt(availableSecs.length)];
      String? secTableId;
      for (final table in tables) {
        for (int i = 0; i < table.seatCount; i++) {
          if (table.students[i] == chosenSec) secTableId = table.id;
        }
      }
      if (secTableId != null && mainTableId != secTableId) return false;
    }

    // Taboo check: across neighbouring desks and within a shared 2-seat desk.
    for (int i = 0; i < tables.length; i++) {
      for (int j = i + 1; j < tables.length; j++) {
        if (_areTablesTabooRelevant(tables[i], tables[j])) {
          for (final s1 in tables[i].students) {
            if (s1 == null) continue;
            for (final s2 in tables[j].students) {
              if (s2 == null) continue;
              if (isTabooPair(s1, s2)) return false;
            }
          }
        }
      }
    }
    for (final table in tables) {
      if (table.seatCount == 2 &&
          table.students[0] != null &&
          table.students[1] != null &&
          isTabooPair(table.students[0]!, table.students[1]!)) {
        return false;
      }
    }

    return true;
  }

  bool isTabooPair(String student1, String student2) =>
      tabooPairs.any((t) => t.involves(student1, student2));

  /// Two desks are "taboo relevant" if they are directly adjacent with no
  /// third desk physically between them.
  bool _areTablesTabooRelevant(SeatTable t1, SeatTable t2) {
    final t1w = AppConfig.tableWidth(t1.seatCount, t1.direction);
    final t1h = AppConfig.tableHeight(t1.seatCount, t1.direction);
    final t2w = AppConfig.tableWidth(t2.seatCount, t2.direction);
    final t2h = AppConfig.tableHeight(t2.seatCount, t2.direction);
    final t1L = t1.position.dx, t1R = t1L + t1w;
    final t1T = t1.position.dy, t1B = t1T + t1h;
    final t2L = t2.position.dx, t2R = t2L + t2w;
    final t2T = t2.position.dy, t2B = t2T + t2h;

    final verticalOverlap = !(t1B < t2T || t1T > t2B);
    if (verticalOverlap) {
      final hDist = t1R < t2L ? t2L - t1R : t1L - t2R;
      if (hDist >= 0 && hDist < AppConfig.neighborThreshold) {
        for (final other in tables) {
          if (other.id == t1.id || other.id == t2.id) continue;
          final ow = AppConfig.tableWidth(other.seatCount, other.direction);
          final oh = AppConfig.tableHeight(other.seatCount, other.direction);
          final oL = other.position.dx, oR = oL + ow;
          final oT = other.position.dy, oB = oT + oh;
          final overlapsT1 = !(oB < t1T || oT > t1B);
          final overlapsT2 = !(oB < t2T || oT > t2B);
          if (overlapsT1 && overlapsT2) {
            final minX = min(t1L, t2L), maxX = max(t1R, t2R);
            if (oR > minX && oL < maxX) return false;
          }
        }
        return true;
      }
    }

    final horizontalOverlap = !(t1R < t2L || t1L > t2R);
    if (horizontalOverlap) {
      final vDist = t1B < t2T ? t2T - t1B : t1T - t2B;
      if (vDist >= 0 && vDist < AppConfig.neighborThreshold) {
        for (final other in tables) {
          if (other.id == t1.id || other.id == t2.id) continue;
          final ow = AppConfig.tableWidth(other.seatCount, other.direction);
          final oh = AppConfig.tableHeight(other.seatCount, other.direction);
          final oL = other.position.dx, oR = oL + ow;
          final oT = other.position.dy, oB = oT + oh;
          final overlapsT1 = !(oR < t1L || oL > t1R);
          final overlapsT2 = !(oR < t2L || oL > t2R);
          if (overlapsT1 && overlapsT2) {
            final minY = min(t1T, t2T), maxY = max(t1B, t2B);
            if (oB > minY && oT < maxY) return false;
          }
        }
        return true;
      }
    }
    return false;
  }

  // Editor round-trips -----------------------------------------------------

  /// Applies the result of the student-list editor and keeps
  /// [fixedSeats] in sync with the new student list.
  Future<void> applyStudentListEdit(
    List<String> newStudents,
    List<FixedSeat> newFixedSeats,
  ) async {
    if (_classId == null) return;
    students = newStudents;
    fixedSeats = newFixedSeats;
    for (final name in students) {
      if (!fixedSeats.any((f) => f.studentName == name)) {
        fixedSeats.add(FixedSeat(studentName: name));
      }
    }
    fixedSeats.removeWhere((f) => !students.contains(f.studentName));
    notifyListeners();
    await DataManager.saveStudents(students, _classId!);
    await _persistFixedSeats();
  }

  Future<void> applyPairEdit(
    List<TabooPair> newTaboo,
    List<FavoritePair> newFavorites,
  ) async {
    if (_classId == null) return;
    tabooPairs = newTaboo;
    favoritePairs = newFavorites;
    notifyListeners();
    await DataManager.saveTabooPairs(tabooPairs, _classId!);
    await DataManager.saveFavoritePairs(favoritePairs, _classId!);
  }

  void updateCanvasSize(double width, double height) {
    canvasWidth = width;
    canvasHeight = height;
  }
}
