// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/featurs/auth/domain/entities/user.dart';

import '../providers/chat_provider.dart';

class InputBottom extends StatelessWidget {
  final String chatId;
  final UserEntity freind;
  const InputBottom({
    Key? key,
    required this.chatId,
    required this.freind,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.purple[200],
      child: Column(
        children: [
          context.watch<ChatProvider>().isReplied
              ? Container(
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  color: Colors.purple[200],
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 35,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context
                              .watch<ChatProvider>()
                              .selectedMessage!
                              .fromName),
                          const SizedBox(height: 5),
                          Text(
                            context.watch<ChatProvider>().selectedMessage!.text,
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            context
                                .read<ChatProvider>()
                                .cancelInReplyModeOnTab();
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                            size: 35,
                          )),
                      const Divider(),
                    ],
                  ))
              : const SizedBox.shrink(),
          Row(children: [
            IconButton(
                onPressed: () {
                  context.read<ChatProvider>().emojiOnTab(context);
                },
                icon: const Icon(Icons.face)),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                autofocus: true,
                controller: context.watch<ChatProvider>().controller,
              ),
            ),
            IconButton(
                onPressed: () {
                  context.read<ChatProvider>().editOrSendOnTab(chatId, freind);
                },
                icon: Icon(context.watch<ChatProvider>().editMode
                    ? Icons.edit
                    : Icons.send))
          ]),
        ],
      ),
    );
  }
}
