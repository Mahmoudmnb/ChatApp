import 'package:chat_app/featurs/chat/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constant.dart';
import '../../../auth/domain/entities/user.dart';

class ChatProvider extends ChangeNotifier {
  List<bool> selectedItems = [];
  List<String> fromMeSelectedMessage = [];
  get selectedItem => selectedItems;
  List<String> copiedMessages = [];
  Message? selectedMessage;
  bool _editMode = false;
  get editMode => _editMode;
  set setEditMode(bool value) {
    _editMode = value;
    notifyListeners();
  }

  void setSelectedItem(bool value, int index) {
    selectedItems[index] = value;
    notifyListeners();
  }

  UserEntity? friend;
  bool _isMainAppBar = true;
  get isMainAppBar => _isMainAppBar;
  set setMainAppBar(bool value) {
    _isMainAppBar = value;
    notifyListeners();
  }

  Future<String> createChat() async {
    var first = await FirebaseFirestore.instance
        .collection('messages')
        .where('to', isEqualTo: Constant.currentUsre.phoneNamber)
        .where('from', isEqualTo: friend!.phoneNamber)
        .get();
    var second = await FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: Constant.currentUsre.phoneNamber)
        .where('to', isEqualTo: friend!.phoneNamber)
        .get();
    if (first.docs.isEmpty && second.docs.isEmpty) {
      var chatId = await FirebaseFirestore.instance.collection('messages').add({
        'from': Constant.currentUsre.phoneNamber,
        'to': friend!.phoneNamber
      });
      return Future.value(chatId.id);
    } else {
      if (first.docs.isNotEmpty) {
        return first.docs.first.id;
      } else {
        return second.docs.first.id;
      }
    }
  }
}
