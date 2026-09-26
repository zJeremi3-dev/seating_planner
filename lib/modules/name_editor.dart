import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/fixed_seat.dart';
import '../models/seat_table.dart';
import 'seat_selection_dialog.dart';

/// Result handed back to the caller when the editor is closed via "save".
class NameListEditResult {
  const NameListEditResult(this.students, this.fixedSeats);
  final List<String> students;
  final List<FixedSeat> fixedSeats;
}

class NameEditor extends StatefulWidget {
  const NameEditor({
    super.key,
    required this.strings,
    required this.students,
    required this.fixedSeats,
    required this.tables,
    required this.rows,
    required this.rowKeyFn,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  final AppStrings strings;
  final List<String> students;
  final List<FixedSeat> fixedSeats;
  final List<SeatTable> tables;
  final List<List<String>> rows;
  final String Function(List<String>) rowKeyFn;
  final double canvasWidth;
  final double canvasHeight;

  @override
  State<NameEditor> createState() => _NameEditorState();
}

class _NameEditorState extends State<NameEditor> {
  late List<String> students;
  late List<FixedSeat> fixedSeats;
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    students = List.from(widget.students);
    fixedSeats = widget.fixedSeats
        .map(
          (f) => FixedSeat(
            studentName: f.studentName,
            allowedSeats: f.allowedSeats
                .map((p) => Map<String, dynamic>.from(p))
                .toList(),
            allowedRowIds: List<String>.from(f.allowedRowIds),
          ),
        )
        .toList();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  FixedSeat _fixedSeatFor(String name) {
    return fixedSeats.firstWhere(
      (f) => f.studentName == name,
      orElse: () {
        final created = FixedSeat(studentName: name);
        fixedSeats.add(created);
        return created;
      },
    );
  }

  String _describe(FixedSeat fixedSeat) {
    final s = widget.strings;
    if (fixedSeat.allowedSeats.isNotEmpty) {
      return s.fixedSeatSummary(fixedSeat.allowedSeats.length);
    }
    if (fixedSeat.allowedRowIds.isNotEmpty) {
      return s.fixedRowSummary(fixedSeat.allowedRowIds.length);
    }
    return s.noFixedSeat;
  }

  Future<void> _chooseSeatFor(FixedSeat fixedSeat) async {
    final result = await showDialog<SeatSelectionResult>(
      context: context,
      builder: (dialogContext) => SeatSelectionDialog(
        strings: widget.strings,
        studentName: fixedSeat.studentName,
        tables: widget.tables,
        rows: widget.rows,
        rowKeyFn: widget.rowKeyFn,
        initial: fixedSeat,
        canvasWidth: widget.canvasWidth,
        canvasHeight: widget.canvasHeight,
      ),
    );
    if (result != null) {
      setState(() {
        fixedSeat.allowedSeats = result.allowedSeats;
        fixedSeat.allowedRowIds = result.allowedRowIds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final filteredStudents = students
        .where((n) => n.toLowerCase().contains(_searchText))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.nameEditorTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: s.save,
            onPressed: () => Navigator.pop(
              context,
              NameListEditResult(students, fixedSeats),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: s.searchStudentLabel,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _nameFocusNode,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: s.studentNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _addStudent(value);
                      _nameFocusNode.requestFocus();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addStudent(_nameController.text),
                  child: Text(s.add),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(
                    child: Text(
                      _searchText.isEmpty
                          ? s.noStudentsInList
                          : s.noStudentsFound,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final name = filteredStudents[index];
                      final fixedSeat = _fixedSeatFor(name);
                      final hasFixedSeat = fixedSeat.hasFixedSeat;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: hasFixedSeat
                                ? Colors.indigo
                                : Colors.grey[300],
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: hasFixedSeat
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            _describe(fixedSeat),
                            style: TextStyle(
                              color: hasFixedSeat ? Colors.indigo : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.tables.isNotEmpty) ...[
                                if (hasFixedSeat)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    tooltip: s.removeFixedSeatTooltip,
                                    onPressed: () =>
                                        setState(() => fixedSeat.clear()),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.indigo,
                                  ),
                                  tooltip: s.configureSeatTooltip,
                                  onPressed: () => _chooseSeatFor(fixedSeat),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => setState(() {
                                  students.remove(name);
                                  fixedSeats.removeWhere(
                                    (f) => f.studentName == name,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addStudent(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return;
    setState(() {
      students.add(name);
      fixedSeats.add(FixedSeat(studentName: name));
      _nameController.clear();
    });
  }
}
