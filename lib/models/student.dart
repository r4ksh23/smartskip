class Student {
  final int id;
  final String name;
  int bunks;

  Student({required this.id, required this.name, this.bunks = 0});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      bunks: json['bunks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'bunks': bunks};
  }
}
