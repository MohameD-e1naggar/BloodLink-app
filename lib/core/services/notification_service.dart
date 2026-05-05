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

  static Future<void> deleteAllForReceiver(String receiverId) async {
    final querySnapshot = await _collection()
        .where('receiverId', isEqualTo: receiverId)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  static Future<void> markAsRead(String notificationId) async {
    await _collection().doc(notificationId).update({'isRead': true});
  }

  static Future<void> delete(String notificationId) async {
    await _collection().doc(notificationId).delete();
  }
}
