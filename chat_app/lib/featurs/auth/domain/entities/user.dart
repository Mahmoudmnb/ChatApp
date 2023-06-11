// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserEntity {
  final String name;
  final String phoneNamber;
  final String token;
  String? imgUrl;

  UserEntity({
    required this.name,
    required this.phoneNamber,
    required this.token,
    this.imgUrl,
  });
  factory UserEntity.fromJson(Map<String, dynamic> map) {
    return UserEntity(
        token: map['token'],
        imgUrl: map['imgUrl'],
        name: map['name'],
        phoneNamber: map['number']);
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': phoneNamber,
      'token': token,
      'imgUrl': imgUrl ?? ''
    };
  }
}
