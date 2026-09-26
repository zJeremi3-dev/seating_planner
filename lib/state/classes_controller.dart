import 'package:flutter/foundation.dart';

import '../data/data_manager.dart';
import '../models/school_class.dart';

/// Owns the list of classes the user has created and which one is
/// currently selected. Board data (desks, students, ...) for the
/// selected class lives in [SeatingController], loaded on selection.
class ClassesController extends ChangeNotifier {
  List<SchoolClass> classes = [];
  String? selectedClassId;
  int _classCounter = 0;
  bool isLoading = true;

  Future<void> load() async {
    classes = await DataManager.loadClasses();
    if (classes.isNotEmpty) {
      final ids = classes
          .map((c) => int.tryParse(c.id.split('_').last) ?? 0)
          .toList();
      _classCounter = ids.reduce((a, b) => a > b ? a : b) + 1;
    }

    final lastId = await DataManager.loadLastClassId();
    if (classes.isNotEmpty &&
        lastId != null &&
        classes.any((c) => c.id == lastId)) {
      selectedClassId = lastId;
    } else {
      selectedClassId = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> selectClass(String classId) async {
    selectedClassId = classId;
    await DataManager.saveLastClassId(classId);
    notifyListeners();
  }

  void goToClassOverview() {
    selectedClassId = null;
    notifyListeners();
  }

  Future<void> addClass(String name) async {
    classes.add(SchoolClass(id: 'class_${_classCounter++}', name: name));
    notifyListeners();
    await DataManager.saveClasses(classes);
  }

  Future<void> renameClass(int index, String newName) async {
    classes[index].name = newName;
    notifyListeners();
    await DataManager.saveClasses(classes);
  }

  Future<void> reorderClasses(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = classes.removeAt(oldIndex);
    classes.insert(newIndex, item);
    notifyListeners();
    await DataManager.saveClasses(classes);
  }

  Future<void> deleteClass(int index) async {
    final classId = classes[index].id;
    await DataManager.deleteClassData(classId);
    classes.removeAt(index);

    if (classes.isEmpty) {
      selectedClassId = null;
    } else if (selectedClassId == classId) {
      selectedClassId = classes.first.id;
      await DataManager.saveLastClassId(selectedClassId!);
    }

    notifyListeners();
    await DataManager.saveClasses(classes);
  }
}
