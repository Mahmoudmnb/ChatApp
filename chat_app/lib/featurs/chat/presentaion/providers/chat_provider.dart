import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constant.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<bool> selectedItems = [];
  String emojiText = '';

  bool checkBoxKey = false;
  bool isReplied = false;
  List<String> fromMeSelectedMessage = [];
  List<String> toMeSelectedMessage = [];

  get selectedItem => selectedItems;
  List<String> copiedMessages = [];
  Message? selectedMessage;
  bool _editMode = false;
  get editMode => _editMode;
  bool _isFaseMode = false;
  get isFaseMode => _isFaseMode;
  set setFaceMode(bool value) {
    _isFaseMode = value;
    notifyListeners();
  }

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

  onLongPressMessage(Message message, bool isme, int index) {
    if (isMainAppBar && !editMode) {
      checkBoxKey = false;
      copiedMessages = [];
      copiedMessages.add(message.text);
      selectedMessage = message;

      isme
          ? fromMeSelectedMessage.add(message.messageId)
          : toMeSelectedMessage.add(message.messageId);
      setMainAppBar = false;
      selectedItems = selectedItems;
      setSelectedItem(true, index);
    }
  }

  onSingleTabMessage(int index, bool isme, Message message, context) {
    if (!isMainAppBar) {
      if (selectedItem[index]) {
        setSelectedItem(false, index);
        isme
            ? fromMeSelectedMessage.remove(message.messageId)
            : toMeSelectedMessage.remove(message.messageId);
        copiedMessages.remove(message.text);
      } else {
        copiedMessages.add(message.text);
        isme ? selectedMessage = message : null;
        isme
            ? fromMeSelectedMessage.add(message.messageId)
            : toMeSelectedMessage.add(message.messageId);
        setSelectedItem(true, index);
      }
      if (!selectedItems.contains(true)) {
        setMainAppBar = true;
      }
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  editOrSendOnTab(String chatId, UserEntity friend, {Message? message}) async {
    if (editMode) {
      setEditMode = false;
      FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .doc(selectedMessage!.messageId)
          .update({'text': controller.text});
      controller.text = '';
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      selectedItems = [];
      emojiText = '';
    } else {
      if (controller.text.isNotEmpty) {
        Message message = Message(
            isreplied: isReplied,
            repliedText: isReplied ? selectedMessage!.text : null,
            fromName: Constant.currentUsre.name,
            messageId: '',
            text: controller.text,
            date: Timestamp.now(), // await NTP.now(),
            from: Constant.currentUsre.phoneNamber,
            to: friend.phoneNamber);
        controller.text = '';
        emojiText = '';
        cancelInReplyModeOnTab();
        var s = await FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .add(message.toJson());
        FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(s.id)
            .update({'messageId': s.id, 'isSent': true});
        moveToEnd();
      }
    }
  }

  void moveToEnd() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  willPopScopeOnTab() {
    //! prevent app from apdating the page on keyboard open
    //! open keyboard on edit
    if (!isMainAppBar) {
      setMainAppBar = true;
      selectedItems = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      return Future.value(false);
    } else if (editMode) {
      _editMode = false;
      controller.text = '';
      selectedItems = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      return Future.value(false);
    } else if (isReplied) {
      cancelInReplyModeOnTab();
    } else {
      return Future.value(true);
    }
  }

  onEmojiSelected(category) {
    emojiText += category.emoji;
    controller.value = TextEditingValue(
      text: emojiText,
      selection: TextSelection.collapsed(offset: emojiText.length),
    );
  }

  cancelOnTab() {
    setMainAppBar = true;
    selectedItems = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  editOnTab() {
    _editMode = true;
    setMainAppBar = true;
    controller.value = TextEditingValue(
      text: selectedMessage!.text,
      selection: TextSelection.collapsed(offset: selectedMessage!.text.length),
    );
  }

  copyOnTab() {
    String clipText = '';
    for (var element in copiedMessages) {
      clipText += element;
      clipText += '      \n';
    }
    Clipboard.setData(ClipboardData(text: clipText));
    setMainAppBar = true;
    selectedItems = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  deleteOnTab(chatId, context, freind) async {
    for (var element in toMeSelectedMessage) {
      var selectedMessage = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .doc(element);
      var s = await selectedMessage.get();
      if (s.data()!['deletedFrom'] == null) {
        selectedMessage
            .update({'deletedFrom': Constant.currentUsre.phoneNamber});
      } else {
        selectedMessage.delete();
      }
    }
    if (fromMeSelectedMessage.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  'Delete message',
                  style: TextStyle(fontSize: 25),
                ),
                content: SizedBox(
                  height: 86,
                  child: Column(
                    children: [
                      const Text(
                        'Do you realy want to delete this message ?',
                        style: TextStyle(fontSize: 15),
                      ),
                      StatefulBuilder(
                        builder: (context, setState) => Row(
                          children: [
                            Checkbox(
                              value: checkBoxKey,
                              onChanged: (value) {
                                setState(
                                  () => checkBoxKey = value!,
                                );
                              },
                            ),
                            Text(
                              'delete also from ${friend!.name} ?',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(checkBoxKey);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 20),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              )).then((value) async {
        if (value != null) {
          for (var element in fromMeSelectedMessage) {
            var selectedMessage = FirebaseFirestore.instance
                .collection('messages')
                .doc(chatId)
                .collection('msg')
                .doc(element);
            if (value == true) {
              selectedMessage.delete();
            } else {
              var s = await selectedMessage.get();
              if (s.data()!['deletedFrom'] == null) {
                selectedMessage
                    .update({'deletedFrom': Constant.currentUsre.phoneNamber});
              } else {
                selectedMessage.delete();
              }
            }
          }
        }
        fromMeSelectedMessage = [];
      });
    }
    setMainAppBar = true;
    selectedItems = [];
    toMeSelectedMessage = [];
  }

  emojiOnTab(BuildContext context) {
    FocusScope.of(context).unfocus();
    setFaceMode = !isFaseMode;
  }

  replyOnTab() {
    setMainAppBar = true;
    isReplied = true;
    selectedItems = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  cancelInReplyModeOnTab() {
    isReplied = false;
    notifyListeners();
  }
}
