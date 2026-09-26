/// A school class the user has created. Each class has its own set of
/// desks, students and pairing rules, stored separately under its [id].
class SchoolClass {
  String id;
  String name;

  SchoolClass({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(id: json['id'] as String, name: json['name'] as String);
  }
}
