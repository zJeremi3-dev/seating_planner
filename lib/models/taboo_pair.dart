/// Two students who must not be seated at the same or directly
/// neighbouring desks.
class TabooPair {
  String student1;
  String student2;

  TabooPair(this.student1, this.student2);

  bool involves(String student1, String student2) =>
      (this.student1 == student1 && this.student2 == student2) ||
      (this.student1 == student2 && this.student2 == student1);

  Map<String, dynamic> toJson() => {'student1': student1, 'student2': student2};

  factory TabooPair.fromJson(Map<String, dynamic> json) {
    return TabooPair(json['student1'] as String, json['student2'] as String);
  }
}
