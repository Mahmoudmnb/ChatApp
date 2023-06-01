import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/constant.dart';
import '../../domain/entities/message.dart';

class ImagePop extends StatefulWidget {
  final Message message;
  final String chatId;
  const ImagePop({
    Key? key,
    required this.message,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ImagePop> createState() => _ImagePopState();
}

class _ImagePopState extends State<ImagePop> {
  DownloadTask? task;
  DownloadManager downloadManager = DownloadManager();
  int nameOfImage = 0;
  @override
  Widget build(BuildContext context) {
    bool isMe = widget.message.from == Constant.currentUsre.phoneNamber;
    return GestureDetector(
      onLongPress: () {
        if (task != null && task!.status.value == DownloadStatus.completed) {
          setState(() {});
        }
        print(task != null ? task!.status.value : '');
      },
      onTap: () {
        if (widget.message.reciverPath == null &&
            widget.message.text != '' &&
            !isMe) {
          downloadImage(widget.message);
        }

        if (isMe && widget.message.senderPath != null) {
          var image = Image.file(File(widget.message.senderPath!)).image;
          showImageViewer(context, image, onViewerDismissed: () {
            print("dismissed");
          });
        } else if (!isMe && widget.message.reciverPath != null) {
          var image = Image.file(File(widget.message.reciverPath!)).image;
          showImageViewer(context, image, onViewerDismissed: () {
            print("dismissed");
          });
        }
      },
      child: Container(
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
                      image: FileImage(File(
                          widget.message.senderPath ?? 'assets/images/1.jpg'))),
                ),
                child: widget.message.text == ''
                    ? const SpinKitCircle(
                        color: Colors.purple,
                      )
                    : const SizedBox.shrink(),
              )
            : SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  children: [
                    widget.message.reciverPath == null
                        ? const SizedBox.shrink()
                        : Image.file(File(widget.message.reciverPath!)),
                    widget.message.reciverPath == null &&
                            task != null &&
                            task!.status.value != DownloadStatus.completed
                        ? ValueListenableBuilder(
                            valueListenable: task!.progress,
                            builder: (context, value, child) {
                              if (value == 1.0) {
                                FirebaseFirestore.instance
                                    .collection('messages')
                                    .doc(widget.chatId)
                                    .collection('msg')
                                    .doc(widget.message.messageId)
                                    .update({
                                  'reciverPath':
                                      '/storage/emulated/0/Download/MyChat/$nameOfImage.jpg'
                                });
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: value,
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                )),
      ),
    );
  }

  downloadImage(Message message) async {
    nameOfImage = Random().nextInt(1000000) + 1000;
    bool isMe = message.from == Constant.currentUsre.phoneNamber;
    if (!isMe && message.reciverPath == null && message.text != '') {
      task = await downloadManager.addDownload(
          message.text, '/storage/emulated/0/Download/MyChat/$nameOfImage.jpg');
      setState(() {});

      downloadManager.getDownload(message.text);
      downloadManager.whenDownloadComplete(message.text);
    }
    print(task?.status.value);
  }
}
