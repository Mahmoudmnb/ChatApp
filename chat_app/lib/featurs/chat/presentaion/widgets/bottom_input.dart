import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/domain/entities/user.dart';
import '../providers/chat_provider.dart';

class InputBottom extends StatelessWidget {
  static var focusScope = FocusNode();
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
                autocorrect: true,
                focusNode: focusScope,
                onChanged: (value) {
                  context.read<ChatProvider>().setInputText = value;
                },
                keyboardType: TextInputType.multiline,
                controller: context.watch<ChatProvider>().controller,
              ),
            ),
            context.watch<ChatProvider>().inputText != ''
                ? IconButton(
                    onPressed: () {
                      context
                          .read<ChatProvider>()
                          .editOrSendOnTab(chatId, freind);
                    },
                    icon: Icon(context.watch<ChatProvider>().editMode
                        ? Icons.edit
                        : Icons.send))
                : Row(
                    children: [
                      IconButton(
                          onPressed: () =>
                              context.read<ChatProvider>().pickImage(chatId),
                          icon: const Icon(Icons.attach_file_sharp)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.mic))
                    ],
                  )
          ]),
        ],
      ),
    );
  }
}
