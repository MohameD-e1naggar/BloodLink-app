class AppNotification {
  static const String collectionName = "Notification";

  final String? id;
  final String? receiverId;
  final String? title;
  final String? body;
  final String? timestamp;
  final bool isRead;
  final String? type;

  AppNotification({
    this.id,
    this.receiverId,
    this.title,
    this.body,
    this.timestamp,
    this.isRead = false,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, {String id = ""}) {
    return AppNotification(
      id: id,
      receiverId: map['receiverId'],
      title: map['title'],
      body: map['body'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
      type: map['type'],
    );
  }
}
