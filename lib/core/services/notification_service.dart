import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:www/core/models/app_notification.dart';

class NotificationService {
  static CollectionReference<AppNotification> _collection() {
    return FirebaseFirestore.instance
        .collection(AppNotification.collectionName)
        .withConverter(
          fromFirestore: (snapshot, _) =>
              AppNotification.fromMap(snapshot.data()!, id: snapshot.id),
          toFirestore: (notif, _) => notif.toMap(),
        );
  }

  static Future<void> create(AppNotification notification) async {
    await _collection().add(notification);
  }

  static Stream<List<AppNotification>> streamForReceiver(String receiverId) {
    return _collection()
        .where('receiverId', isEqualTo: receiverId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => doc.data()).toList();
          list.sort((a, b) => (b.timestamp ?? '').compareTo(a.timestamp ?? ''));
          return list;
        });
  }
}
