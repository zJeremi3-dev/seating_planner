/// A favorite pairing: [mainStudent] is seated with one randomly chosen
/// student from [secondaryStudents] at the same desk whenever possible.
class FavoritePair {
  String mainStudent;
  List<String> secondaryStudents;

  FavoritePair(this.mainStudent, this.secondaryStudents);

  Map<String, dynamic> toJson() => {
    'mainStudent': mainStudent,
    'secondaryStudents': secondaryStudents,
  };

  factory FavoritePair.fromJson(Map<String, dynamic> json) {
    return FavoritePair(
      json['mainStudent'] as String,
      List<String>.from(json['secondaryStudents'] as List),
    );
  }
}
