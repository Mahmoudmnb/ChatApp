import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/widgets.dart';

class ChatePage extends StatefulWidget {
  final UserEntity friend;
  final String chatId;
  const ChatePage({required this.chatId, required this.friend, super.key});
  @override
  State<ChatePage> createState() => _ChatePageState();
}

class _ChatePageState extends State<ChatePage> {
  @override
  void initState() {
    if (context.read<ChatProvider>().isConvertedMode) {
      context.read<ChatProvider>().sendConvertedMessage(widget.chatId);
    }
    super.initState();
  }

  @override
  void dispose() {
    // context.read<ChatProvider>().controller.dispose();
    // context.read<ChatProvider>().scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          return context.read<ChatProvider>().willPopScopeOnTab();
        },
        child: Scaffold(
            bottomNavigationBar: context.watch<ChatProvider>().isFaseMode
                ? const EmojiPickerBuilde()
                : const SizedBox.shrink(),
            appBar: context.watch<ChatProvider>().isMainAppBar
                ? mainAppBar(widget.friend.name)
                : aternativeAppBar(),
            body: SafeArea(
              child: Column(
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
                          controller:
                              context.watch<ChatProvider>().scrollController,
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) {
                            context
                                .read<ChatProvider>()
                                .selectedItems
                                .add(false);
                            Message message = Message.fromJson(
                                snapshot.data!.docs[index].data());
                            bool isme = message.from ==
                                Constant.currentUsre.phoneNamber;
                            return message.deletedFrom ==
                                    Constant.currentUsre.phoneNamber
                                ? const SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () {
                                      context
                                          .read<ChatProvider>()
                                          .onSingleTabMessage(
                                              index, isme, message, context);
                                    },
                                    onLongPress: () {
                                      context
                                          .read<ChatProvider>()
                                          .onLongPressMessage(
                                              message, isme, index);
                                    },
                                    child: MessageRow(
                                        chatId: widget.chatId,
                                        index: index,
                                        isme: isme,
                                        friend: widget.friend,
                                        message: message));
                          },
                        );
                      } else {
                        return const Text('loading');
                        //! convert to animated loading widget
                      }
                    },
                  )),
                  !context.read<ChatProvider>().isMainAppBar &&
                          !context.read<ChatProvider>().editMode
                      ? const AlternativeBottomInput()
                      : InputBottom(
                          chatId: widget.chatId, freind: widget.friend),
                ],
              ),
            )),
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
            const SizedBox(width: 2),
            Text(name),
          ],
        ),
      );
  AppBar aternativeAppBar() => AppBar(
        leading: IconButton(
            onPressed: () {
              context.read<ChatProvider>().cancelOnTab();
            },
            icon: const Icon(Icons.cancel)),
        title: Text((context.watch<ChatProvider>().toMeSelectedMessage.length +
                context.watch<ChatProvider>().fromMeSelectedMessage.length)
            .toString()),
        actions: [
          context.watch<ChatProvider>().toMeSelectedMessage.isEmpty &&
                  context.read<ChatProvider>().fromMeSelectedMessage.length == 1
              ? IconButton(
                  onPressed: () {
                    context.read<ChatProvider>().editOnTab();
                  },
                  icon: const Icon(Icons.edit))
              : const SizedBox.shrink(),
          IconButton(
              onPressed: () {
                context.read<ChatProvider>().copyOnTab();
              },
              icon: const Icon(Icons.copy)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)),
          IconButton(
              onPressed: () async {
                context
                    .read<ChatProvider>()
                    .deleteOnTab(widget.chatId, context, widget.friend);
              },
              icon: const Icon(Icons.delete)),
        ],
      );
}
