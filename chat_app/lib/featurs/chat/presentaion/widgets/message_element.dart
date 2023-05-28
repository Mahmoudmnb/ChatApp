import 'package:chat_app/featurs/chat/presentaion/widgets/image_pop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import 'message_pop.dart';
import 'repied_message_pop.dart';

class MessageRow extends StatelessWidget {
  final int index;
  final bool isme;
  final UserEntity friend;
  final Message message;
  final String chatId;

  const MessageRow({
    Key? key,
    required this.chatId,
    required this.index,
    required this.isme,
    required this.friend,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: !context.read<ChatProvider>().isMainAppBar &&
                  context.watch<ChatProvider>().selectedItem[index]
              ? Colors.grey[200]
              : Colors.transparent),
      child: Column(
        children: [
          Row(
            children: [
              !context.watch<ChatProvider>().isMainAppBar
                  ? Container(
                      margin: const EdgeInsets.all(5),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(width: 3, color: Colors.white)),
                      child: context.watch<ChatProvider>().selectedItem[index]
                          ? const Icon(Icons.check)
                          : const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
              Expanded(
                child: Container(
                    alignment: message.from == friend.phoneNamber
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: message.type == 'Image'
                        ? ImagePop(
                            message: message,
                          )
                        : message.isreplied
                            ? RepliedMessagePop(
                                chatId: chatId, isme: isme, message: message)
                            : MessagePop(
                                chatId: chatId,
                                isme: isme,
                                message: message,
                              )),
              ),
            ],
          ),
          const SizedBox(height: 2)
        ],
      ),
    );
  }
}
