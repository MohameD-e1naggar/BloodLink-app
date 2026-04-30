import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:www/Backend/models/Request.dart';
import 'package:www/Backend/models/Inventory.dart';
import 'models/User.dart' as my_user;

class FirestoreHandler{

  static CollectionReference<my_user.User> getUserCollection(){
    var collection = FirebaseFirestore.instance.collection(my_user.User.collectionName).withConverter(
        fromFirestore: (snapshot, options) {
          return my_user.User.fromMap(snapshot.data()!);
        },
        toFirestore: (user, options) {
          return user.toMap();
        }
    );
    return collection;
  }

  static CollectionReference<Request> getReqCollection(){
    var collection = FirebaseFirestore.instance.collection(Request.collectionName).withConverter(
        fromFirestore: (snapshot, options) {
          return Request.fromMap(snapshot.data()!,id:snapshot.id);
        },
        toFirestore: (req, options) {
          return req.toMap();
        }
    );
    return collection;
  }



  static Future<List<Request>> getIncomingRequests(String bloodBankId) async {
    final collection = getReqCollection();

    final activeStatuses = [
      RequestStatus.pending.name,
      RequestStatus.approved.name,
    ];

    final donorQuery = await collection
        .where("bloodBankId", isEqualTo: bloodBankId)
        .where("reqStatus", whereIn: activeStatuses)
        .where("reqSender", isEqualTo: ReqSender.donor.name)
        .get();

    final hospitalQuery = await collection
        .where("reqSender", isEqualTo: ReqSender.hospital.name)
        .where("reqStatus", whereIn: activeStatuses)
        .get();

    final allDocs = [...donorQuery.docs, ...hospitalQuery.docs];

    final unique = {for (var doc in allDocs) doc.id: doc}.values;

    return unique.map((doc) => doc.data()).toList();
  }


  static Future<void> updateStatus(String requestId, RequestStatus newStatus,
      ) async {
    final collection = getReqCollection();

    await collection.doc(requestId).update({
      'reqStatus': newStatus.name,
    });
  }


  static Future<void> updateDonorsCounter(String requestId,) async {
    final collection = getReqCollection();

    await collection.doc(requestId).update({
      'donorsAcceptedCriticalReqNum': FieldValue.increment(1),
    });
  }

  static Future<void> updateReqUnitsCounter(String requestId) async {
    final docRef = getReqCollection().doc(requestId);
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final req = snapshot.data();
      if (req == null) return;
      
      int currentUnits = req.units ?? 0;
      if (currentUnits > 0) {
        currentUnits -= 1;
        
        transaction.update(docRef, {
          'units': currentUnits,
          if (currentUnits == 0) 'reqStatus': RequestStatus.approved.name,
        });
      }
    });
  }

  static Future<void> updateReqBloodBank(String requestId,String bloodBankName,String bloodBankId) async {
    final collection = getReqCollection();

    await collection.doc(requestId).update({
      'bloodBankName': bloodBankName,
      'bloodBankId' : bloodBankId,
    });
  }


  static DocumentReference<Inventory> getInventoryDoc(String userId){
    var userCollection = getUserCollection();
    var userDoc = userCollection.doc(userId);
    var inventoryCollection = userDoc.collection(Inventory.collectionName).doc('main').withConverter(
      fromFirestore: (snapshot, options) {
        return Inventory.fromMap(snapshot.data());
      },
      toFirestore: (inventory, options) {
        return inventory.toMap();
      },
    );
    return inventoryCollection;
  }





  static Future<void> createReq(Request req){
    var collection = getReqCollection();
    var docRef = collection.add(req);
    return docRef;
  }


  static Future<List<Request>> getReqByDonorId(String id) async {
    var userCollectionReference = getReqCollection();

    var querySnapshot = await userCollectionReference
        .where('donorId', isEqualTo: id)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data())
        .toList();
  }


  static Future<List<Request>> getCriticalReq() async {
    var userCollectionReference = getReqCollection();

    var querySnapshot = await userCollectionReference
        .where('urgency', isEqualTo: Urgency.critical.name)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  static Future<void> createUser(my_user.User user){
    var collection = getUserCollection();
    var docRef = collection.doc(user.id);
     docRef.set(user);

    if (user.type == my_user.UserTypes.bloodBank.name) {
       createInventory(user.id!);
    }
    return docRef.set(user) ;
   
  }


  static Future<void> createInventory(String userId) {
    return getInventoryDoc(userId).set( Inventory(
      aPos: 0,
      bPos: 0,
      oPos: 0,
      abPos: 0,
      aNeg: 0,
      bNeg: 0,
      oNeg: 0,
      abNeg: 0, ),
    );
  }

  static Future<Inventory?> getInventory(String userId) async {
    final doc = await getInventoryDoc(userId).get();
    return doc.data();
  }
  static Future<void> updateBloodType(
      String userId,
      String type,
      int value,
      ) {
    return getInventoryDoc(userId).update({
      type: value,
    });
  }

  static Future<my_user.User?> getUser(String userId) async {
    var userCollectionReference = getUserCollection();
    var snapshot = await userCollectionReference.doc(userId).get();

    if (!snapshot.exists) return null;

    return snapshot.data();
  }

  static Future<List<my_user.User>> getUsersByType(String type) async {
    var userCollectionReference = getUserCollection();

    var querySnapshot = await userCollectionReference
        .where('type', isEqualTo: type)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  static Future<void> deleteRequest(String requestId) async {
    final collection = getReqCollection();
    await collection.doc(requestId).delete();
  }

  // --- Local Request States stored in Firestore User Document ---

  static Future<void> addAcceptedReq(String userId, String requestId) async {
    final doc = getUserCollection().doc(userId);
    await doc.update({
      'acceptedCriticalReqs': FieldValue.arrayUnion([requestId])
    });
  }

  static Future<void> addRejectedReq(String userId, String requestId) async {
    final doc = getUserCollection().doc(userId);
    await doc.update({
      'rejectedCriticalReqs': FieldValue.arrayUnion([requestId])
    });
  }

  static Future<void> addHiddenReq(String userId, String requestId) async {
    final doc = getUserCollection().doc(userId);
    await doc.update({
      'hiddenCriticalReqs': FieldValue.arrayUnion([requestId])
    });
  }

}