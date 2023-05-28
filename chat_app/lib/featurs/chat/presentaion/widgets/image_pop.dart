import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constant.dart';
import '../../domain/entities/message.dart';

class ImagePop extends StatelessWidget {
  final Message message;
  const ImagePop({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMe = message.from == Constant.currentUsre.phoneNamber;
    if (!isMe && message.text != '') {
      //!fdfdfdfdfdf
      // FileDownloader.downloadFile(
      //     name: 'MyChat/mnb.jpg',
      //     onProgress: (fileName, progress) => print(progress),
      //     onDownloadError: (errorMessage) => print(errorMessage),
      //     onDownloadCompleted: (path) => print(path),
      //     url:
      //         'https://firebasestorage.googleapis.com/v0/b/chat-app-76800.appspot.com/o/chat%2Faaa?alt=media&token=f5ec409e-c5f9-4160-a961-4d231eab610e');
    }
    return Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(15)),
        child: isMe
            ? Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(
                          File(message.senderPath ?? 'assets/images/1.jpg'))),
                ),
                child: message.text == ''
                    ? const SpinKitCircle(
                        color: Colors.purple,
                      )
                    : const SizedBox.shrink(),
              )
            : Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(
                          File(message.reciverPath ?? 'assets/images/1.jpg'))),
                ),
                child: message.text == ''
                    ? const SpinKitCircle(
                        color: Colors.purple,
                      )
                    : const SizedBox.shrink(),
              ));
  }
}
