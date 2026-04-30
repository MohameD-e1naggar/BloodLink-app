import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:www/core/models/user.dart' as my_user;
import 'package:www/core/services/inventory_service.dart';

class UserService {
  static CollectionReference<my_user.User> _collection() {
    return FirebaseFirestore.instance
        .collection(my_user.User.collectionName)
        .withConverter(
          fromFirestore: (snapshot, _) => my_user.User.fromMap(snapshot.data()!),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  static Future<void> createUser(my_user.User user) async {
    final docRef = _collection().doc(user.id);
    await docRef.set(user);

    if (user.type == my_user.UserTypes.bloodBank.name) {
      await InventoryService.create(user.id!);
    }
  }

  static Future<my_user.User?> getUser(String userId) async {
    final snapshot = await _collection().doc(userId).get();
    if (!snapshot.exists) return null;
    return snapshot.data();
  }

  static Future<List<my_user.User>> getUsersByType(String type) async {
    final snapshot = await _collection().where('type', isEqualTo: type).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<void> addAcceptedReq(String userId, String requestId) async {
    await _collection().doc(userId).update({
      'acceptedCriticalReqs': FieldValue.arrayUnion([requestId]),
    });
  }

  static Future<void> addRejectedReq(String userId, String requestId) async {
    await _collection().doc(userId).update({
      'rejectedCriticalReqs': FieldValue.arrayUnion([requestId]),
    });
  }

  static Future<void> addHiddenReq(String userId, String requestId) async {
    await _collection().doc(userId).update({
      'hiddenCriticalReqs': FieldValue.arrayUnion([requestId]),
    });
  }
}
