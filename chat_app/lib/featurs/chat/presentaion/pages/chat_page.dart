import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';

// ignore: must_be_immutable
class ChatePage extends StatefulWidget {
  final UserEntity friend;
  final String chatId;
  const ChatePage({required this.chatId, required this.friend, super.key});
  @override
  State<ChatePage> createState() => _ChatePageState();
}

class _ChatePageState extends State<ChatePage> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<bool> selectedItems = [];
  List<String> toMeSelectedMessage = [];
  bool checkBoxKey = false;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          //! prevent app from apdating the page on keyboard open
          //! open keyboard on edit
          if (!context.read<ChatProvider>().isMainAppBar) {
            context.read<ChatProvider>().setMainAppBar = true;
            selectedItems = [];
            context.read<ChatProvider>().fromMeSelectedMessage = [];
            toMeSelectedMessage = [];
            return Future.value(false);
          } else if (context.read<ChatProvider>().editMode) {
            context.read<ChatProvider>().setEditMode = false;
            controller.text = '';
            selectedItems = [];
            context.read<ChatProvider>().fromMeSelectedMessage = [];
            toMeSelectedMessage = [];
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: context.watch<ChatProvider>().isMainAppBar
                ? mainAppBar(widget.friend.name)
                : aternativeAppBar(),
            body: Column(
              children: [
                Expanded(
                    child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .doc(widget.chatId)
                      .collection('msg')
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (con, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        controller: scrollController,
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (ctx, index) {
                          selectedItems.add(false);
                          Message message = Message.fromJson(
                              snapshot.data!.docs[index].data());
                          bool isme =
                              message.from == Constant.currentUsre.phoneNamber;
                          return message.deletedFrom ==
                                  Constant.currentUsre.phoneNamber
                              ? const SizedBox.shrink()
                              : GestureDetector(
                                  onTap: () {
                                    if (!context
                                        .read<ChatProvider>()
                                        .isMainAppBar) {
                                      if (context
                                          .read<ChatProvider>()
                                          .selectedItem[index]) {
                                        context
                                            .read<ChatProvider>()
                                            .setSelectedItem(false, index);
                                        isme
                                            ? context
                                                .read<ChatProvider>()
                                                .fromMeSelectedMessage
                                                .remove(message.messageId)
                                            : toMeSelectedMessage
                                                .remove(message.messageId);
                                        context
                                            .read<ChatProvider>()
                                            .copiedMessages
                                            .remove(message.text);
                                      } else {
                                        context
                                            .read<ChatProvider>()
                                            .copiedMessages
                                            .add(message.text);
                                        isme
                                            ? context
                                                .read<ChatProvider>()
                                                .selectedMessage = message
                                            : null;
                                        isme
                                            ? context
                                                .read<ChatProvider>()
                                                .fromMeSelectedMessage
                                                .add(message.messageId)
                                            : toMeSelectedMessage
                                                .add(message.messageId);
                                        context
                                            .read<ChatProvider>()
                                            .setSelectedItem(true, index);
                                      }
                                      if (!selectedItems.contains(true)) {
                                        context
                                            .read<ChatProvider>()
                                            .setMainAppBar = true;
                                      }
                                    } else {
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  onLongPress: () {
                                    if (context
                                            .read<ChatProvider>()
                                            .isMainAppBar &&
                                        !context
                                            .read<ChatProvider>()
                                            .editMode) {
                                      checkBoxKey = false;
                                      context
                                          .read<ChatProvider>()
                                          .copiedMessages = [];
                                      context
                                          .read<ChatProvider>()
                                          .copiedMessages
                                          .add(message.text);
                                      isme
                                          ? context
                                              .read<ChatProvider>()
                                              .selectedMessage = message
                                          : null;
                                      isme
                                          ? context
                                              .read<ChatProvider>()
                                              .fromMeSelectedMessage
                                              .add(message.messageId)
                                          : toMeSelectedMessage
                                              .add(message.messageId);
                                      context
                                          .read<ChatProvider>()
                                          .setMainAppBar = false;
                                      context
                                          .read<ChatProvider>()
                                          .selectedItems = selectedItems;
                                      context
                                          .read<ChatProvider>()
                                          .setSelectedItem(true, index);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: !context
                                                    .read<ChatProvider>()
                                                    .isMainAppBar &&
                                                context
                                                    .watch<ChatProvider>()
                                                    .selectedItem[index]
                                            ? Colors.grey[200]
                                            : Colors.transparent),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            !context
                                                    .watch<ChatProvider>()
                                                    .isMainAppBar
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.all(5),
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            width: 3,
                                                            color:
                                                                Colors.white)),
                                                    child: context
                                                            .watch<
                                                                ChatProvider>()
                                                            .selectedItem[index]
                                                        ? const Icon(
                                                            Icons.check)
                                                        : const SizedBox
                                                            .shrink(),
                                                  )
                                                : const SizedBox.shrink(),
                                            Expanded(
                                              child: Container(
                                                alignment: message.from ==
                                                        widget
                                                            .friend.phoneNamber
                                                    ? Alignment.centerLeft
                                                    : Alignment.centerRight,
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15,
                                                      vertical: 10),
                                                  width: deviceSize.width * 0.6,
                                                  decoration: BoxDecoration(
                                                      color: isme
                                                          ? Colors.yellow
                                                          : Colors.amber,
                                                      borderRadius: BorderRadius.only(
                                                          topRight: const Radius
                                                              .circular(15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  isme
                                                                      ? 15
                                                                      : 0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  isme
                                                                      ? 0
                                                                      : 15),
                                                          topLeft: const Radius
                                                              .circular(15))),
                                                  child: Text(
                                                    message.text,
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2)
                                      ],
                                    ),
                                  ),
                                );
                        },
                      );
                    } else {
                      return const Text('loading');
                    }
                  },
                )),
                !context.read<ChatProvider>().isMainAppBar &&
                        !context.read<ChatProvider>().editMode
                    ? alternativBottomInput()
                    : bottonInput()
              ],
            )),
      ),
    );
  }

  void moveToEnd() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  bottonInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      width: double.infinity,
      color: Colors.pink,
      child: Row(children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            autofocus: true,
            controller: controller,
          ),
        ),
        IconButton(
            onPressed: () async {
              if (context.read<ChatProvider>().editMode) {
                context.read<ChatProvider>().setEditMode = false;
                FirebaseFirestore.instance
                    .collection('messages')
                    .doc(widget.chatId)
                    .collection('msg')
                    .doc(
                        context.read<ChatProvider>().selectedMessage!.messageId)
                    .update({'text': controller.text});
                controller.text = '';
                context.read<ChatProvider>().fromMeSelectedMessage = [];
                toMeSelectedMessage = [];
                selectedItems = [];
              } else {
                if (controller.text.isNotEmpty) {
                  Message message = Message(
                      messageId: '',
                      text: controller.text,
                      date: DateTime.now(),
                      from: Constant.currentUsre.phoneNamber,
                      to: widget.friend.phoneNamber);
                  controller.text = '';
                  var s = await FirebaseFirestore.instance
                      .collection('messages')
                      .doc(widget.chatId)
                      .collection('msg')
                      .add(message.toJson());
                  await FirebaseFirestore.instance
                      .collection('messages')
                      .doc(widget.chatId)
                      .collection('msg')
                      .doc(s.id)
                      .update({'messageId': s.id});
                  moveToEnd();
                }
              }
            },
            icon: Icon(context.watch<ChatProvider>().editMode
                ? Icons.edit
                : Icons.send))
      ]),
    );
  }

  alternativBottomInput() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.purple),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
              onPressed: () {},
              label: const Text(
                'reply',
                style: TextStyle(fontSize: 20),
              ),
              icon: const Icon(Icons.arrow_back)),
          TextButton.icon(
              onPressed: () {},
              label: const Text(
                'anwer',
                style: TextStyle(fontSize: 20),
              ),
              icon: const Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }

  AppBar mainAppBar(String name) => AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.phone)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
        title: Row(
          children: [
            const CircleAvatar(),
            const SizedBox(width: 5),
            Text(name),
          ],
        ),
      );
  AppBar aternativeAppBar() => AppBar(
        leading: IconButton(
            onPressed: () {
              context.read<ChatProvider>().setMainAppBar = true;
              selectedItems = [];
              context.read<ChatProvider>().fromMeSelectedMessage = [];
              toMeSelectedMessage = [];
            },
            icon: const Icon(Icons.cancel)),
        title: Text((toMeSelectedMessage.length +
                context.watch<ChatProvider>().fromMeSelectedMessage.length)
            .toString()),
        actions: [
          toMeSelectedMessage.isEmpty &&
                  context.read<ChatProvider>().fromMeSelectedMessage.length == 1
              ? IconButton(
                  onPressed: () {
                    context.read<ChatProvider>().setEditMode = true;
                    context.read<ChatProvider>().setMainAppBar = true;
                    controller.value = TextEditingValue(
                      text: context.read<ChatProvider>().selectedMessage!.text,
                      selection: TextSelection.collapsed(
                          offset: context
                              .read<ChatProvider>()
                              .selectedMessage!
                              .text
                              .length),
                    );
                  },
                  icon: const Icon(Icons.edit))
              : const SizedBox.shrink(),
          IconButton(
              onPressed: () {
                String clipText = '';
                for (var element
                    in context.read<ChatProvider>().copiedMessages) {
                  clipText += element;
                  clipText += '      \n';
                }
                Clipboard.setData(ClipboardData(text: clipText));
                context.read<ChatProvider>().setMainAppBar = true;
                selectedItems = [];
                context.read<ChatProvider>().fromMeSelectedMessage = [];
                toMeSelectedMessage = [];
              },
              icon: const Icon(Icons.copy)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)),
          IconButton(
              onPressed: () async {
                for (var element in toMeSelectedMessage) {
                  var selectedMessage = FirebaseFirestore.instance
                      .collection('messages')
                      .doc(widget.chatId)
                      .collection('msg')
                      .doc(element);
                  var s = await selectedMessage.get();
                  if (s.data()!['deletedFrom'] == null) {
                    selectedMessage.update(
                        {'deletedFrom': Constant.currentUsre.phoneNamber});
                  } else {
                    selectedMessage.delete();
                  }
                }
                if (context
                    .read<ChatProvider>()
                    .fromMeSelectedMessage
                    .isNotEmpty) {
                  // ignore: use_build_context_synchronously
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
                                    builder: (ctx, setState) => Row(
                                      children: [
                                        Checkbox(
                                          value: checkBoxKey,
                                          onChanged: (value) {
                                            setState(() {
                                              checkBoxKey = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          'delete also from ${widget.friend.name} ?',
                                          style: const TextStyle(fontSize: 15),
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
                      for (var element in context
                          .read<ChatProvider>()
                          .fromMeSelectedMessage) {
                        var selectedMessage = FirebaseFirestore.instance
                            .collection('messages')
                            .doc(widget.chatId)
                            .collection('msg')
                            .doc(element);
                        if (value == true) {
                          selectedMessage.delete();
                        } else {
                          var s = await selectedMessage.get();
                          if (s.data()!['deletedFrom'] == null) {
                            selectedMessage.update({
                              'deletedFrom': Constant.currentUsre.phoneNamber
                            });
                          } else {
                            selectedMessage.delete();
                          }
                        }
                      }
                    }
                    context.read<ChatProvider>().fromMeSelectedMessage = [];
                  });
                }
                context.read<ChatProvider>().setMainAppBar = true;
                selectedItems = [];
                toMeSelectedMessage = [];
              },
              icon: const Icon(Icons.delete)),
        ],
      );
}
