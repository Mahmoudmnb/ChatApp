class UserEntity {
  final String name;
  final String phoneNamber;

  UserEntity({required this.name, required this.phoneNamber});
  factory UserEntity.fromJson(Map<String, dynamic> map) {
    return UserEntity(name: map['name'], phoneNamber: map['number']);
  }
}
