// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:chat_app/featurs/auth/domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../domain/entities/message.dart';

class MessagePop extends StatelessWidget {
  final bool isme;
  final MessageModel message;
  final String chatId;
  final UserEntity friend;
  const MessagePop({
    Key? key,
    required this.isme,
    required this.message,
    required this.chatId,
    required this.friend,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    if (!isme) {
      if (message.messageId != '') {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection('msg')
            .doc(message.messageId)
            .update({'isReseved': true});
      }
    }
    // else {
    //   if (!message.isReseved) {
    //     context.read<ChatProvider>().sendPushMessage(
    //         message.text, Constant.currentUsre.name, friend.token);
    //   }
    // }
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: deviceSize.width * 0.6,
      decoration: BoxDecoration(
          color: isme ? Colors.yellow : Colors.amber,
          borderRadius: BorderRadius.only(
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isme ? 15 : 0),
              bottomRight: Radius.circular(isme ? 0 : 15),
              topLeft: const Radius.circular(15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.fromName,
          ),
          const SizedBox(height: 5),
          Text(
            message.text,
            style: const TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  '${message.date.toDate().hour}:${message.date.toDate().minute}'),
              const SizedBox(width: 5),
              isme
                  ? message.isReseved == true
                      ? const Icon(Icons.done_all)
                      : message.isSent == true
                          ? const Icon(Icons.check)
                          : const SpinKitCircle(
                              size: 30,
                              color: Colors.blueAccent,
                            )
                  : const SizedBox.shrink()
            ],
          ),
        ],
      ),
    );
  }
}
