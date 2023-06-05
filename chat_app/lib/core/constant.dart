import 'dart:io';

import 'package:chat_app/featurs/auth/domain/entities/user.dart';

class Constant {
  static UserEntity currentUsre = UserEntity(name: '', phoneNamber: '');
  static Directory? localPath;
}
