import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String fromName;
  final String text;
  final Timestamp date;
  final String from;
  final String to;
  final String messageId;
  String? deletedFrom;
  bool isreplied;
  String? repliedText;
  bool isSent;
  bool isReseved;

  Message({
    this.isreplied = false,
    this.repliedText,
    this.isReseved = false,
    this.isSent = false,
    required this.fromName,
    required this.messageId,
    required this.text,
    required this.date,
    required this.from,
    required this.to,
    this.deletedFrom,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
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
