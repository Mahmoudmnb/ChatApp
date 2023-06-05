// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserEntity {
  final String name;
  final String phoneNamber;
  String? imgUrl;

  UserEntity({
    required this.name,
    required this.phoneNamber,
    this.imgUrl,
  });
  factory UserEntity.fromJson(Map<String, dynamic> map) {
    return UserEntity(
        imgUrl: map['imgUrl'], name: map['name'], phoneNamber: map['number']);
  }
}
