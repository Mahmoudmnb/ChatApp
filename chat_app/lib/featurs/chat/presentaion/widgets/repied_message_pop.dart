import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../domain/entities/message.dart';

class RepliedMessagePop extends StatelessWidget {
  final Message message;
  final bool isme;
  final String chatId;
  const RepliedMessagePop({
    Key? key,
    required this.message,
    required this.isme,
    required this.chatId,
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
          const SizedBox(height: 5),
          Text(message.fromName),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: isme ? Colors.yellow[600] : Colors.amber[600],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.repliedText!,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message.text,
            style: const TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${(message.date)}:${(message.date)}'),
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
