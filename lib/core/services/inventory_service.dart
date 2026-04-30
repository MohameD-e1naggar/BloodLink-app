import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:www/core/models/blood_inventory.dart';
import 'package:www/core/models/user.dart' as my_user;

class InventoryService {
  static DocumentReference<Inventory> _doc(String userId) {
    return FirebaseFirestore.instance
        .collection(my_user.User.collectionName)
        .doc(userId)
        .collection(Inventory.collectionName)
        .doc('main')
        .withConverter(
          fromFirestore: (snapshot, _) => Inventory.fromMap(snapshot.data()),
          toFirestore: (inventory, _) => inventory.toMap(),
        );
  }

  static Future<void> create(String userId) {
    return _doc(userId).set(Inventory(
      aPos: 0, bPos: 0, oPos: 0, abPos: 0,
      aNeg: 0, bNeg: 0, oNeg: 0, abNeg: 0,
    ));
  }

  static Future<Inventory?> get(String userId) async {
    final doc = await _doc(userId).get();
    return doc.data();
  }

  static Future<void> updateBloodType(String userId, String type, int value) {
    return _doc(userId).update({type: value});
  }

  static Future<void> updateInventory(String userId, Inventory inventory) {
    return _doc(userId).set(inventory);
  }
}
