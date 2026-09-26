import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/favorite_pair.dart';
import '../models/taboo_pair.dart';

class PairEditResult {
  const PairEditResult(this.tabooPairs, this.favoritePairs);
  final List<TabooPair> tabooPairs;
  final List<FavoritePair> favoritePairs;
}

class PairEditor extends StatefulWidget {
  const PairEditor({
    super.key,
    required this.strings,
    required this.tabooPairs,
    required this.favoritePairs,
    required this.availableStudents,
  });

  final AppStrings strings;
  final List<TabooPair> tabooPairs;
  final List<FavoritePair> favoritePairs;
  final List<String> availableStudents;

  @override
  State<PairEditor> createState() => _PairEditorState();
}

class _PairEntry {
  const _PairEntry(
    this.student1,
    this.student2, {
    required this.isTaboo,
    this.favoritePair,
  });
  final String student1;
  final String student2;
  final bool isTaboo;
  final FavoritePair? favoritePair;
}

class _PairEditorState extends State<PairEditor> {
  late List<TabooPair> tabooPairs;
  late List<FavoritePair> favoritePairs;
  String? selectedStudent1;
  String? selectedStudent2;
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    tabooPairs = List.from(widget.tabooPairs);
    favoritePairs = widget.favoritePairs
        .map(
          (f) => FavoritePair(
            f.mainStudent,
            List<String>.from(f.secondaryStudents),
          ),
        )
        .toList();
  }

  Set<String> get _usedMainStudents =>
      favoritePairs.map((f) => f.mainStudent).toSet();

  Future<void> _showAddSecondaryDialog(FavoritePair pair) async {
    final s = widget.strings;
    String? chosen;
    final alreadyUsed = {pair.mainStudent, ...pair.secondaryStudents};
    final available = widget.availableStudents
        .where((n) => !alreadyUsed.contains(n))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.noMoreStudentsAvailableMsg)));
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.addSecDialogTitle(pair.mainStudent),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          content: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: s.selectStudentLabel,
              border: const OutlineInputBorder(),
            ),
            initialValue: chosen,
            items: available
                .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                .toList(),
            onChanged: (v) => setDialogState(() => chosen = v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: chosen == null
                  ? null
                  : () {
                      setState(() => pair.secondaryStudents.add(chosen!));
                      Navigator.pop(dialogContext);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(s.add),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final showTaboo = !_showFavorites;
    final allPairs = [
      ...tabooPairs.map(
        (p) => _PairEntry(p.student1, p.student2, isTaboo: true),
      ),
      ...favoritePairs.map(
        (p) => _PairEntry(
          p.mainStudent,
          p.secondaryStudents.join(' | '),
          isTaboo: false,
          favoritePair: p,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.pairEditorTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => Navigator.pop(
              context,
              PairEditResult(tabooPairs, favoritePairs),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: s.tabooFavoriteSwitchTooltip,
                    child: Switch(
                      value: _showFavorites,
                      onChanged: (value) =>
                          setState(() => _showFavorites = value),
                      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return const Icon(
                            Icons.favorite,
                            color: Colors.white,
                          );
                        }
                        return const Icon(Icons.block, color: Colors.white);
                      }),
                      thumbColor: WidgetStateProperty.all(
                        const Color(0xFF535353),
                      ),
                      activeTrackColor: Colors.greenAccent[100],
                      inactiveTrackColor: Colors.redAccent[100],
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.grey[700],
                      ),
                      trackOutlineWidth: WidgetStateProperty.all(2.5),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      showTaboo ? s.tabooExplanation : s.favoriteExplanation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showTaboo
                          ? s.tabooExplanationDetail
                          : s.favoriteExplanationDetail,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: showTaboo
                                  ? s.student1Label
                                  : s.mainStudentLabel,
                              border: const OutlineInputBorder(),
                            ),
                            initialValue: selectedStudent1,
                            items: widget.availableStudents
                                .where(
                                  (n) =>
                                      showTaboo ||
                                      !_usedMainStudents.contains(n),
                                )
                                .map(
                                  (n) => DropdownMenuItem(
                                    value: n,
                                    child: Text(n),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedStudent1 = value),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            showTaboo ? Icons.block : Icons.favorite,
                            color: showTaboo ? Colors.red : Colors.green,
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: showTaboo
                                  ? s.student2Label
                                  : s.secStudentLabel,
                              border: const OutlineInputBorder(),
                            ),
                            initialValue: selectedStudent2,
                            items: widget.availableStudents
                                .map(
                                  (n) => DropdownMenuItem(
                                    value: n,
                                    child: Text(n),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedStudent2 = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedStudent1 == null ||
                            selectedStudent2 == null) {
                          return;
                        }
                        if (selectedStudent1 == selectedStudent2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.chooseTwoDifferentStudentsMsg),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          if (showTaboo) {
                            tabooPairs.add(
                              TabooPair(selectedStudent1!, selectedStudent2!),
                            );
                          } else {
                            favoritePairs.add(
                              FavoritePair(selectedStudent1!, [
                                selectedStudent2!,
                              ]),
                            );
                          }
                          selectedStudent1 = null;
                          selectedStudent2 = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showTaboo
                            ? Colors.red[400]
                            : Colors.green[400],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        showTaboo ? s.addTabooPair : s.addFavoritePair,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          if (allPairs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.block, size: 14, color: Colors.red[400]),
                  const SizedBox(width: 4),
                  Text(
                    s.tabooBadge(tabooPairs.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.favorite, size: 14, color: Colors.green[400]),
                  const SizedBox(width: 4),
                  Text(
                    s.favoriteBadge(favoritePairs.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: allPairs.isEmpty
                ? Center(child: Text(s.noPairsDefined))
                : ListView.builder(
                    itemCount: allPairs.length,
                    itemBuilder: (context, index) {
                      final entry = allPairs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: entry.isTaboo
                            ? ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  child: Icon(
                                    Icons.block,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  '${entry.student1}  ⛔  ${entry.student2}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  s.tabooCardSubtitle,
                                  style: TextStyle(
                                    color: Colors.red[300],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setState(
                                    () => tabooPairs.removeWhere(
                                      (p) =>
                                          p.student1 == entry.student1 &&
                                          p.student2 == entry.student2,
                                    ),
                                  ),
                                ),
                              )
                            : _buildFavoriteCard(entry.favoritePair!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoritePair pair) {
    final s = widget.strings;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(Icons.favorite, color: Colors.green[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      pair.mainStudent,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.favorite, color: Colors.green, size: 14),
                    ...pair.secondaryStudents.asMap().entries.map(
                      (e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (e.key > 0)
                            Text(
                              ' | ',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (pair.secondaryStudents.length == 1) {
                                      favoritePairs.remove(pair);
                                    } else {
                                      pair.secondaryStudents.removeAt(e.key);
                                    }
                                  }),
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  s.favoriteCardSubtitle,
                  style: TextStyle(
                    color: Colors.green[300],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            tooltip: s.addSecTooltip,
            onPressed: () => _showAddSecondaryDialog(pair),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: s.deleteFavoritePairTooltip,
            onPressed: () => setState(() => favoritePairs.remove(pair)),
          ),
        ],
      ),
    );
  }
}
