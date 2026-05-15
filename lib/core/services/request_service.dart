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
    if (req.donorId != null && req.donorId!.isNotEmpty) {
      await NotificationService.create(AppNotification(
        receiverId: req.donorId,
        title: 'Request Sent',
        body:
            'Done sending a request to ${req.bloodBankName ?? "the blood bank"} and we are waiting for acceptance.',
        timestamp: DateTime.now().toIso8601String(),
        type: 'request_sent_donor',
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
    
    final bloodBankQuery = await collection()
        .where('reqSender', isEqualTo: ReqSender.bloodBank.name)
        .where('reqStatus', whereIn: activeStatuses)
        .get();

    final allDocs = [...donorQuery.docs, ...hospitalQuery.docs, ...bloodBankQuery.docs];
    final unique = {for (var doc in allDocs) doc.id: doc}.values;
    
    // Filter out requests sent by THIS blood bank (using requesterId)
    return unique
        .map((doc) => doc.data())
        .where((req) => req.reqSender != ReqSender.bloodBank.name || req.requesterId != bloodBankId)
        .toList();
  }

  static Future<List<Request>> getOutgoingForBloodBank(String bloodBankId) async {
    final snapshot = await collection()
        .where('requesterId', isEqualTo: bloodBankId)
        .where('reqSender', isEqualTo: ReqSender.bloodBank.name)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<void> updateStatus(String requestId, RequestStatus newStatus) async {
    final col = collection();

    // Build the base update map
    final Map<String, dynamic> updateData = {'reqStatus': newStatus.name};

    // Fetch the request first to check urgency
    final doc = await col.doc(requestId).get();
    if (!doc.exists) return;
    final req = doc.data()!;

    if (newStatus == RequestStatus.approved && req.urgency == Urgency.critical.name) {
      // Start the 6-hour countdown
      updateData['approvedAt'] = DateTime.now().toIso8601String();
    } else if (newStatus == RequestStatus.fulfilled || newStatus == RequestStatus.rejected) {
      // Clear the countdown
      updateData['approvedAt'] = null;
    }

    await col.doc(requestId).update(updateData);

    // If fulfilled and sender was a blood bank, increment their inventory
    if (newStatus == RequestStatus.fulfilled && req.reqSender == ReqSender.bloodBank.name) {
      if (req.requesterId != null && req.bloodType != null && req.units != null) {
        await _incrementInventory(req.requesterId!, req.bloodType!, req.units!);
      }
    }

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

    if (req.donorId != null && req.donorId!.isNotEmpty) {
      if (newStatus == RequestStatus.approved) {
        await NotificationService.create(AppNotification(
          receiverId: req.donorId,
          title: 'Request Approved',
          body:
              '${req.bloodBankName ?? "A Blood Bank"} has approved your request for ${req.bloodType} blood.',
          timestamp: DateTime.now().toIso8601String(),
          type: 'request_accepted_donor',
        ));
      } else if (newStatus == RequestStatus.rejected) {
        await NotificationService.create(AppNotification(
          receiverId: req.donorId,
          title: 'Request Rejected',
          body:
              '${req.bloodBankName ?? "A Blood Bank"} has rejected your request for ${req.bloodType} blood.',
          timestamp: DateTime.now().toIso8601String(),
          type: 'request_rejected_donor',
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
        if (currentUnits == 0) {
          justApproved = true;
          reqData = req;
          transaction.update(docRef, {
            'units': currentUnits,
            'reqStatus': RequestStatus.approved.name,
            'approvedAt': DateTime.now().toIso8601String(),
          });
        } else {
          transaction.update(docRef, {'units': currentUnits});
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

  static Future<void> _incrementInventory(String bloodBankId, String bloodType, int units) async {
    final docRef = FirebaseFirestore.instance
        .collection('User')
        .doc(bloodBankId)
        .collection('inventory')
        .doc('main');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;

      int currentUnits = data[bloodType] ?? 0;
      transaction.update(docRef, {bloodType: currentUnits + units});
    });
  }
}
