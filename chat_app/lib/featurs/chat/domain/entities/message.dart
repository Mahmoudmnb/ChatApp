import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  bool isLonding;
  double progressDownloading;
  bool isDownloded;
  String? senderPath;
  String? reciverPath;
  final String fromName;
  final String text;
  final Timestamp date;
  final String from;
  final String to;
  final String messageId;
  final String type;
  String? deletedFrom;
  bool isreplied;
  String? repliedText;
  bool isSent;
  bool isReseved;

  Message({
    this.progressDownloading = 0,
    this.isLonding = false,
    this.isDownloded = false,
    this.senderPath,
    this.reciverPath,
    required this.fromName,
    required this.text,
    required this.date,
    required this.from,
    required this.to,
    required this.messageId,
    required this.type,
    this.deletedFrom,
    this.isreplied = false,
    this.repliedText,
    this.isSent = false,
    this.isReseved = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isDownloded': isDownloded,
      'senderPath': senderPath,
      'reciverPath': reciverPath,
      'type': type,
      'isreplied': isreplied,
      'repliedText': repliedText,
      'isReseved': isReseved,
      'isSent': isSent,
      'fromName': fromName,
      'deletedFrom': deletedFrom,
      'messageId': messageId,
      'text': text,
      'date': date,
      'from': from,
      'to': to,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      reciverPath: map['reciverPath'],
      senderPath: map['senderPath'],
      isDownloded: map['isDownloded'],
      type: map['type'],
      repliedText: map['repliedText'],
      isreplied: map['isreplied'] ?? false,
      isReseved: map['isReseved'] ?? false,
      isSent: map['isSent'] ?? false, //! not allowed to be null
      fromName: map['fromName'] ?? '', //! not allowedto be null
      deletedFrom: map['deletedFrom'],
      messageId: map['messageId'] ?? '',
      text: map['text'] as String,
      date: map['date'],
      from: map['from'] as String,
      to: map['to'] as String,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Message.fromJson(Map<String, dynamic> source) =>
      Message.fromMap(source);
}
