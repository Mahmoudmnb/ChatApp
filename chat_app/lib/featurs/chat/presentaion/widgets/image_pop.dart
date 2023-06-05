// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constant.dart';
import '../../domain/entities/message.dart';

class ImagePop extends StatefulWidget {
  DownloadTask? task;
  final Message message;
  final String chatId;
  ImagePop({
    Key? key,
    required this.message,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ImagePop> createState() => _ImagePopState();
}

class _ImagePopState extends State<ImagePop> {
  DownloadManager downloadManager = DownloadManager();

  @override
  Widget build(BuildContext context) {
    bool isMe = widget.message.from == Constant.currentUsre.phoneNamber;
    Size deviceSize = MediaQuery.of(context).size;
    if (!isMe) {
      if (widget.message.messageId != '') {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.chatId)
            .collection('msg')
            .doc(widget.message.messageId)
            .update({'isReseved': true});
      }
    }

    return widget.message.text == '' && !isMe
        ? const SizedBox.shrink()
        : GestureDetector(
            onLongPress: () {
              print(widget.message.imageHeight);
            },
            onTap: () {
              if (widget.message.reciverPath == null &&
                  widget.message.text != '' &&
                  !isMe) {
                if (widget.task == null) {
                  downloadImage(widget.message);
                } else if (widget.task!.status.value ==
                    DownloadStatus.downloading) {
                  setState(() {});
                  downloadManager.pauseDownload(widget.message.text);
                } else if (widget.task!.status.value == DownloadStatus.paused) {
                  setState(() {});
                  downloadManager.resumeDownload(widget.message.text);
                }

                if (isMe && widget.message.text != '') {
                  var image =
                      Image.file(File(widget.message.senderPath!)).image;
                  showImageViewer(context, image);
                } else if (!isMe && widget.message.reciverPath != null) {
                  var image =
                      Image.file(File(widget.message.reciverPath!)).image;
                  showImageViewer(context, image);
                }
              } else {
                if (isMe && widget.message.senderPath != null) {
                  showImageViewer(
                      context, FileImage(File(widget.message.senderPath!)));
                } else if (widget.message.reciverPath != null) {
                  showImageViewer(
                      context, FileImage(File(widget.message.reciverPath!)));
                }
              }
            },
            child: Container(
                constraints: BoxConstraints(
                    maxHeight: deviceSize.height * 0.45,
                    maxWidth: deviceSize.width * 0.5),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15)),
                child: Stack(
                  children: [
                    isMe
                        ? SizedBox(
                            child: widget.message.text == ''
                                ? Stack(children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(
                                            File(widget.message.senderPath!))),
                                    const Icon(Icons.cancel),
                                    const SpinKitCircle(
                                      color: Colors.purple,
                                    ),
                                  ])
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                        File(widget.message.senderPath!))),
                          )
                        : SizedBox(
                            child: Stack(
                            children: [
                              widget.message.reciverPath == null
                                  ? SizedBox(
                                      child: widget.task == null ||
                                              widget.task!.status.value ==
                                                      DownloadStatus.paused &&
                                                  widget.task!.status.value !=
                                                      DownloadStatus.downloading
                                          ? const Align(
                                              child: Icon(
                                              MdiIcons.downloadOutline,
                                              size: 40,
                                            ))
                                          : const SizedBox.shrink())
                                  : File(widget.message.reciverPath!).isAbsolute
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.file(
                                            File(widget.message.reciverPath!),
                                          ),
                                        )
                                      : const CircularProgressIndicator(
                                          value: 1,
                                        ),
                              widget.message.reciverPath == null &&
                                      widget.task != null &&
                                      widget.task!.status.value !=
                                          DownloadStatus.completed &&
                                      widget.task!.status.value !=
                                          DownloadStatus.paused
                                  ? ValueListenableBuilder(
                                      valueListenable: widget.task!.progress,
                                      builder: (context, value, child) {
                                        if (value == 1.0) {
                                          FirebaseFirestore.instance
                                              .collection('messages')
                                              .doc(widget.chatId)
                                              .collection('msg')
                                              .doc(widget.message.messageId)
                                              .update({
                                            'reciverPath':
                                                '${Constant.localPath!.path}${widget.message.messageId}.jpg'
                                          });
                                        }
                                        return Center(
                                          child: Stack(children: [
                                            Align(
                                              child: CircularProgressIndicator(
                                                value: value,
                                              ),
                                            ),
                                            const Align(
                                                child: Icon(Icons.cancel))
                                          ]),
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          )),
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                              '${widget.message.date.toDate().hour}:${widget.message.date.toDate().minute}'),
                          const SizedBox(width: 5),
                          isMe
                              ? widget.message.isReseved == true
                                  ? const Icon(Icons.done_all)
                                  : widget.message.isSent == true
                                      ? const Icon(Icons.check)
                                      : const SpinKitCircle(
                                          size: 30,
                                          color: Colors.blueAccent,
                                        )
                              : const SizedBox.shrink()
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                          onPressed: () {
                            print('save image');
                          },
                          icon: const Icon(Icons.more_vert)),
                    ),
                  ],
                )));
  }

  downloadImage(Message message) async {
    bool isMe = message.from == Constant.currentUsre.phoneNamber;
    if (!isMe && message.reciverPath == null && message.text != '') {
      widget.task = await downloadManager.addDownload(
          message.text, '${Constant.localPath!.path}${message.messageId}.jpg');
      setState(() {});
      downloadManager.getDownload(message.text);
    }
  }
}
