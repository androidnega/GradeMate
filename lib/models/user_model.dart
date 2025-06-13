class UserModel {
  final String id;
  final String name;
  final String email;
  final String? institution;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.institution,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      institution: map['institution'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'institution': institution};
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? institution,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      institution: institution ?? this.institution,
    );
  }
}
