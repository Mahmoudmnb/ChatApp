import 'dart:io';

import 'package:chat_app/featurs/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

class Constant {
  static UserEntity currentUsre =
      UserEntity(token: '', name: '', phoneNamber: '');
  static Directory? localPath;
  //! chat page colors
  static Color chatColor = const Color(0xBD9B9B00);
  static Color appBarColor = const Color(0xf8f8f800);
  static Color iconColor = const Color(0x00e39801);
  static Color sendMessageColor = const Color(0x0092d4dd);
  static Color resivedMessageColor = const Color(0x00ffffff);
  static Color dateColor = const Color(0x00464646);
  static Color repliedMessageColor = const Color(0x00d9d9d9);
  static Color inputBottomColor = const Color(0x00f8f8f8);
  static Color textInputColor = const Color(0x00f4f4f4);

  //! Home page colors
  static Color subText = const Color(0x005e5e5e);

  //! dark mode colors
  static Color dAppBarColor = const Color(0x00131313);
  static Color dIconColor = const Color(0x00f1c40f);
  static Color dSndMessageColor = const Color(0x001C6D78);
  static Color dDateColor = const Color(0x00EAE6E6);
  static Color dResivedMessageColor = const Color(0x00131313);
  static Color dRepliedMessageColor = const Color(0x00D9D9D9);
  static Color dInputBottomColor = const Color(0x00131313);
}
