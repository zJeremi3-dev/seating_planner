import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../l10n/app_strings.dart';
import '../state/providers.dart';

class ClassEditor extends ConsumerStatefulWidget {
  const ClassEditor({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<ClassEditor> createState() => _ClassEditorState();
}

class _ClassEditorState extends ConsumerState<ClassEditor> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addClass() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(classesControllerProvider).addClass(name);
    _nameController.clear();
  }

  Future<void> _renameClass(int index, String currentName) async {
    final s = widget.strings;
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.renameClassTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: s.newClassNameLabel,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.pop(dialogContext, value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: Text(s.rename),
          ),
        ],
      ),
    );
    if (result != null && result != currentName) {
      ref.read(classesControllerProvider).renameClass(index, result);
    }
  }

  Future<void> _confirmDeleteClass(int index, String name) async {
    final s = widget.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.deleteClassTitle),
        content: Text(s.deleteClassBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(classesControllerProvider).deleteClass(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final classesController = ref.watch(classesControllerProvider);
    final classes = classesController.classes;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: s.className,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addClass(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addClass, child: Text(s.add)),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: classes.isEmpty
              ? Center(
                  child: Text(
                    s.noClassesHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ReorderableGridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: classes.length,
                    onReorder: (oldIndex, newIndex) =>
                        classesController.reorderClasses(oldIndex, newIndex),
                    dragStartDelay: const Duration(milliseconds: 100),
                    itemBuilder: (context, index) {
                      final schoolClass = classes[index];
                      return ElevatedButton(
                        key: ValueKey(schoolClass.id),
                        onPressed: () =>
                            classesController.selectClass(schoolClass.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007878),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                schoolClass.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _confirmDeleteClass(index, schoolClass.name);
                                }
                                if (value == 'rename') {
                                  _renameClass(index, schoolClass.name);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.drive_file_rename_outline_rounded,
                                        color: Colors.blueGrey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(s.rename),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(s.delete),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
