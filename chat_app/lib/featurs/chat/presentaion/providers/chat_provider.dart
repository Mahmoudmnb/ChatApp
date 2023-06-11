// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/featurs/chat/domain/entities/message.dart';

import '../../../../core/constant.dart';
import '../../../auth/domain/entities/user.dart';

class ChatProvider extends ChangeNotifier {
  FocusNode focusNode = FocusNode(debugLabel: 'mnb');
  Map<String, int> numOfNewMessages = {};
  final Map<String, double> _imageProgressValue = {};
  get imgeProgressValue => _imageProgressValue;
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<bool> selectedItems = [];
  String emojiText = '';
  File? pickedImage;
  bool checkBoxKey = false;
  bool isReplied = false;
  bool isConvertedMode = false;
  List<String> fromMeSelectedMessage = [];
  List<String> toMeSelectedMessage = [];
  get selectedItem => selectedItems;
  List<MessageModel> copiedMessages = [];
  MessageModel? selectedMessage;
  bool _editMode = false;
  get editMode => _editMode;
  bool _isFaseMode = false;
  get isFaseMode => _isFaseMode;
  String? _inputText = '';
  get inputText => _inputText;
  set setConvertedMode(bool value) {
    isConvertedMode = value;
    notifyListeners();
  }

  set setInputText(String value) {
    _inputText = value;
    notifyListeners();
  }

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
        'fromToken': Constant.currentUsre.token,
        'toToken': friend!.token,
        'from': Constant.currentUsre.phoneNamber,
        'fromName': Constant.currentUsre.name,
        'toName': friend!.name,
        'to': friend!.phoneNamber
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constant.currentUsre.phoneNamber)
          .collection('friends')
          .doc(friend!.phoneNamber)
          .set({
        'to': friend!.phoneNamber,
        'toToken': friend!.token,
        'toName': friend!.name,
        'chatId': chatId.id
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(friend!.phoneNamber)
          .collection('friends')
          .doc(Constant.currentUsre.phoneNamber)
          .set({
        'to': Constant.currentUsre.phoneNamber,
        'toToken': Constant.currentUsre.token,
        'toName': Constant.currentUsre.name,
        'chatId': chatId.id
      });
      return Future.value(chatId.id);
    } else {
      String chatId = '';
      if (first.docs.isNotEmpty) {
        chatId = first.docs.first.id;
      } else {
        chatId = second.docs.first.id;
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(Constant.currentUsre.phoneNamber)
          .collection('friends')
          .doc(friend!.phoneNamber)
          .set({
        'to': friend!.phoneNamber,
        'toToken': friend!.token,
        'toName': friend!.name,
        'chatId': chatId,
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(friend!.phoneNamber)
          .collection('friends')
          .doc(Constant.currentUsre.phoneNamber)
          .set({
        'to': Constant.currentUsre.phoneNamber,
        'toToken': Constant.currentUsre.token,
        'toName': Constant.currentUsre.name,
        'chatId': chatId
      });
      return chatId;
    }
  }

  onLongPressMessage(MessageModel message, bool isme, int index) {
    if (isMainAppBar && !editMode) {
      checkBoxKey = false;
      copiedMessages = [];
      copiedMessages.add(message);
      selectedMessage = message;

      isme
          ? fromMeSelectedMessage.add(message.messageId)
          : toMeSelectedMessage.add(message.messageId);
      setMainAppBar = false;
      selectedItems = selectedItems;
      setSelectedItem(true, index);
    }
  }

  onSingleTabMessage(int index, bool isme, MessageModel message, context) {
    if (!isMainAppBar) {
      if (selectedItem[index]) {
        setSelectedItem(false, index);
        isme
            ? fromMeSelectedMessage.remove(message.messageId)
            : toMeSelectedMessage.remove(message.messageId);
        copiedMessages.remove(message);
      } else {
        copiedMessages.add(message);
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

  editOrSendOnTab(String chatId, UserEntity friend) async {
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
        MessageModel message = MessageModel(
            type: 'Message',
            isreplied: isReplied,
            repliedText: isReplied ? selectedMessage!.text : null,
            fromName: Constant.currentUsre.name,
            messageId: '',
            text: controller.text,
            date: Timestamp.now(),
            from: Constant.currentUsre.phoneNamber,
            to: friend.phoneNamber);
        sendPushMessage(
            controller.text,
            Constant.currentUsre.name,
            friend.token,
            Constant.currentUsre.phoneNamber,
            chatId,
            Constant.currentUsre);
        controller.text = '';
        _inputText = '';
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
    notifyListeners();
  }

  void moveToEnd() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  willPopScopeOnTab() {
    if (!isMainAppBar) {
      setMainAppBar = true;
      selectedItems = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      setFaceMode = false;
      return Future.value(false);
    } else if (editMode) {
      setFaceMode = false;

      _editMode = false;
      controller.text = '';
      selectedItems = [];
      fromMeSelectedMessage = [];
      toMeSelectedMessage = [];
      return Future.value(false);
    } else if (isReplied) {
      cancelInReplyModeOnTab();
    } else if (_isFaseMode) {
      setFaceMode = !_isFaseMode;
    } else {
      setFaceMode = false;
      return Future.value(true);
    }
  }

  onEmojiSelected(category) {
    emojiText += category.emoji;
    _inputText = emojiText;
    controller.value = TextEditingValue(
      text: emojiText,
      selection: TextSelection.collapsed(offset: emojiText.length),
    );
    notifyListeners();
  }

  cancelOnTab() {
    setMainAppBar = true;
    selectedItems = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
  }

  Future<void> editOnTab(BuildContext context) async {
    //* open keyboard on edit
    _editMode = true;
    setMainAppBar = true;
    controller.value = TextEditingValue(
      text: selectedMessage!.text,
      selection: TextSelection.collapsed(offset: selectedMessage!.text.length),
    );
    FocusScope.of(context).requestFocus(focusNode);
  }

  copyOnTab() {
    String clipText = '';
    for (var element in copiedMessages) {
      clipText += element.text;
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
        FirebaseStorage.instance.ref('chat').child(element).delete();
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
              FirebaseStorage.instance.ref('chat').child(element).delete();
            } else {
              var s = await selectedMessage.get();
              if (s.data()!['deletedFrom'] == null) {
                selectedMessage
                    .update({'deletedFrom': Constant.currentUsre.phoneNamber});
              } else {
                selectedMessage.delete();
                FirebaseStorage.instance.ref('chat').child(element).delete();
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
    if (!_isFaseMode) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus(focusNode);
    }
    setFaceMode = !isFaseMode;
    notifyListeners();
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

  pickImage(String chatId) async {
    pickedImage = null;
    ImagePicker picker = ImagePicker();
    var r = await picker.pickImage(source: ImageSource.gallery);
    if (r != null) {
      pickedImage = File(r.path);
    }

    if (pickedImage != null) {
      var decodedImage =
          await decodeImageFromList(pickedImage!.readAsBytesSync());
      MessageModel message = MessageModel(
          imageHeight: decodedImage.height * 1.0,
          imageWidth: decodedImage.width * 1.0,
          senderPath: pickedImage!.path,
          type: 'Image',
          isreplied: isReplied,
          repliedText: isReplied ? selectedMessage!.text : null,
          fromName: Constant.currentUsre.name,
          messageId: '',
          text: '',
          date: Timestamp.now(),
          from: Constant.currentUsre.phoneNamber,
          to: friend!.phoneNamber);
      var s = await FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection('msg')
          .add(message.toJson());
      var comImage = await FlutterImageCompress.compressAndGetFile(
          pickedImage!.absolute.path,
          '/data/user/0/com.example.chat_app/cache/${s.id}.jpg');
      File pickeImageFile = File(comImage!.path);
      FirebaseStorage.instance
          .ref('chat')
          .child(s.id)
          .putFile(pickeImageFile)
          .snapshotEvents
          .listen((event) async {
        if (event.state == TaskState.success) {
          FirebaseFirestore.instance
              .collection('messages')
              .doc(chatId)
              .collection('msg')
              .doc(s.id)
              .update({
            'messageId': s.id,
            'isSent': true,
            'text': await event.ref.getDownloadURL()
          });
          sendPushMessage('Image', Constant.currentUsre.name, friend!.token,
              Constant.currentUsre.phoneNamber, chatId, friend!);
          _imageProgressValue[s.id] = 0;
        }
      });
    }
    moveToEnd();
    notifyListeners();
  }

  convertMessageOnTab(BuildContext context) {
    isConvertedMode = true;
    setMainAppBar = true;
    selectedItems = [];
    fromMeSelectedMessage = [];
    toMeSelectedMessage = [];
    Navigator.of(context).pop();
    notifyListeners();
  }

  sendConvertedMessage(String chatId) async {
    for (MessageModel element in copiedMessages) {
      var message = MessageModel(
          type: 'Message',
          fromName: element.fromName,
          messageId: element.messageId,
          text: element.text,
          date: Timestamp.now(),
          from: element.from,
          to: element.to);
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
    isConvertedMode = false;

    notifyListeners();
  }

  imgageProgressDownload(double progress, String imageId) {
    _imageProgressValue[imageId] = progress;
    notifyListeners();
  }

  onDoneImageDownlad(String imageId) {
    _imageProgressValue.remove(imageId);
    notifyListeners();
  }

  void sendPushMessage(String body, String title, String token,
      String senderNum, String chatId, UserEntity localFreind) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAApisdxjw:APA91bGy4m2H8sUXgHbDIuof13KaMqTjapWYf15Gcmd1-Z1xeA3Y858rUaoojcGh6lii9-p9wS6aMacQgxzVYqK9-bFPpQyf7QfrlgNOyyhkEFMM6_1iFyFMX_rHp1FZiq7gHf76IbJA'
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': 'dbfood'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'senderNum': senderNum,
              'chatId': chatId,
              'friend': json.encode(localFreind.toJson())
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }
}
