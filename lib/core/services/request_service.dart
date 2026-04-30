import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:www/core/models/blood_request.dart';
import 'package:www/core/models/app_notification.dart';
import 'package:www/core/services/notification_service.dart';

class RequestService {
  static CollectionReference<Request> collection() {
    return FirebaseFirestore.instance
        .collection(Request.collectionName)
        .withConverter(
          fromFirestore: (snapshot, _) =>
              Request.fromMap(snapshot.data()!, id: snapshot.id),
          toFirestore: (req, _) => req.toMap(),
        );
  }

  static Future<void> create(Request req) async {
    await collection().add(req);
    if (req.bloodBankId != null && req.bloodBankId!.isNotEmpty) {
      await NotificationService.create(AppNotification(
        receiverId: req.bloodBankId,
        title: 'New Blood Request',
        body:
            'Hospital ${req.hospitalName ?? "Unknown"} requested ${req.units} units of ${req.bloodType}.',
        timestamp: DateTime.now().toIso8601String(),
        type: 'request_incoming',
      ));
    }
  }

  static Future<void> delete(String requestId) async {
    await collection().doc(requestId).delete();
  }

  static Future<List<Request>> getByDonorId(String donorId) async {
    final snapshot = await collection()
        .where('donorId', isEqualTo: donorId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<Request>> getCritical() async {
    final snapshot = await collection()
        .where('urgency', isEqualTo: Urgency.critical.name)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<List<Request>> getIncomingForBloodBank(String bloodBankId) async {
    final activeStatuses = [
      RequestStatus.pending.name,
      RequestStatus.approved.name,
    ];

    final donorQuery = await collection()
        .where('bloodBankId', isEqualTo: bloodBankId)
        .where('reqStatus', whereIn: activeStatuses)
        .where('reqSender', isEqualTo: ReqSender.donor.name)
        .get();

    final hospitalQuery = await collection()
        .where('reqSender', isEqualTo: ReqSender.hospital.name)
        .where('reqStatus', whereIn: activeStatuses)
        .get();

    final allDocs = [...donorQuery.docs, ...hospitalQuery.docs];
    final unique = {for (var doc in allDocs) doc.id: doc}.values;
    return unique.map((doc) => doc.data()).toList();
  }

  static Future<void> updateStatus(String requestId, RequestStatus newStatus) async {
    final col = collection();
    await col.doc(requestId).update({'reqStatus': newStatus.name});

    final doc = await col.doc(requestId).get();
    if (!doc.exists) return;
    final req = doc.data()!;

    if (req.bloodBankId != null && req.bloodBankId!.isNotEmpty) {
      if (newStatus == RequestStatus.approved) {
        await NotificationService.create(AppNotification(
          receiverId: req.bloodBankId,
          title: 'Request Approved',
          body: 'You have approved a request for ${req.bloodType} blood.',
          timestamp: DateTime.now().toIso8601String(),
          type: 'request_approved',
        ));
      } else if (newStatus == RequestStatus.fulfilled) {
        await NotificationService.create(AppNotification(
          receiverId: req.bloodBankId,
          title: 'Request Fulfilled',
          body:
              'The hospital has marked your blood request for ${req.bloodType} as fulfilled.',
          timestamp: DateTime.now().toIso8601String(),
          type: 'request_fulfilled',
        ));
      }
    }

    if (req.hospitalId != null && req.hospitalId!.isNotEmpty) {
      if (newStatus == RequestStatus.approved &&
          req.bloodBankId != null &&
          req.bloodBankId!.isNotEmpty) {
        await NotificationService.create(AppNotification(
          receiverId: req.hospitalId,
          title: 'Request Accepted',
          body:
              '${req.bloodBankName ?? "A Blood Bank"} has accepted your request for ${req.bloodType}.',
          timestamp: DateTime.now().toIso8601String(),
          type: 'request_accepted_hospital',
        ));
      } else if (newStatus == RequestStatus.rejected) {
        await NotificationService.create(AppNotification(
          receiverId: req.hospitalId,
          title: 'Request Rejected',
          body:
              '${req.bloodBankName ?? "A Blood Bank"} has rejected your request for ${req.bloodType}.',
          timestamp: DateTime.now().toIso8601String(),
          type: 'request_rejected_hospital',
        ));
      }
    }
  }

  static Future<void> updateBloodBank(
    String requestId,
    String bloodBankName,
    String bloodBankId,
  ) async {
    await collection().doc(requestId).update({
      'bloodBankName': bloodBankName,
      'bloodBankId': bloodBankId,
    });
  }

  static Future<void> incrementDonorsCounter(String requestId) async {
    await collection().doc(requestId).update({
      'donorsAcceptedCriticalReqNum': FieldValue.increment(1),
    });
  }

  static Future<void> decrementUnits(String requestId) async {
    final docRef = collection().doc(requestId);
    bool justApproved = false;
    Request? reqData;

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
        if (currentUnits == 0) {
          justApproved = true;
          reqData = req;
        }
      }
    });

    if (justApproved &&
        reqData != null &&
        reqData!.hospitalId != null &&
        reqData!.hospitalId!.isNotEmpty) {
      await NotificationService.create(AppNotification(
        receiverId: reqData!.hospitalId,
        title: 'Emergency Request Approved',
        body:
            'Donors have accepted enough units for your ${reqData!.bloodType} emergency request!',
        timestamp: DateTime.now().toIso8601String(),
        type: 'emergency_approved_hospital',
      ));
    }
  }
}
