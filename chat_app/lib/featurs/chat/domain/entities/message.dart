class Message {
  late final String text;
  final DateTime date;
  final String from;
  final String to;
  final String messageId;
  String? deletedFrom;
  Message({
    required this.messageId,
    required this.text,
    required this.date,
    required this.from,
    required this.to,
    this.deletedFrom,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deletedFrom': deletedFrom,
      'messageId': messageId,
      'text': text,
      'date': date.millisecondsSinceEpoch,
      'from': from,
      'to': to,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      deletedFrom: map['deletedFrom'],
      messageId: map['messageId'] ?? '',
      text: map['text'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      from: map['from'] as String,
      to: map['to'] as String,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Message.fromJson(Map<String, dynamic> source) =>
      Message.fromMap(source);
}
