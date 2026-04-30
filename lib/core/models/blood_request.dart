enum RequestStatus {
  pending,
  approved,
  fulfilled,
  rejected,
}

enum Urgency {
  normal,
  critical,
}

enum ReqSender{
  donor,
  hospital,
}

class Request {
  static const String collectionName = "Request";

  final String? donorId;
  final String? hospitalId;
  final String? bloodBankName;
  final String? hospitalName;
  final String? bloodBankId;
  final String? bloodType;
  final String? reqSender;
  final int? units;
  final String? date;
  final String? time;
  final String? reqStatus;
  final String? urgency;
  final String? id ;
  final int? donorsAcceptedCriticalReqNum;

  Request( {
    this.donorId,
    this.hospitalName,
    this.hospitalId,
    this.bloodBankName,
    this.bloodBankId,
    this.bloodType,
    this.units,
    this.date,
    this.time,
    this.reqStatus,
    this.urgency,
    this.reqSender,
    this.id,
    this.donorsAcceptedCriticalReqNum,
  });

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'hospitalId': hospitalId,
      'bloodBankName': bloodBankName,
      'bloodBankId': bloodBankId,
      'bloodType': bloodType,
      'units': units,
      'date': date,
      'time': time,
      'reqStatus': reqStatus,
      'urgency': urgency,
      'reqSender': reqSender,
      'hospitalName': hospitalName,
      'donorsAcceptedCriticalReqNum':donorsAcceptedCriticalReqNum,
    };
  }

  factory Request.fromMap(Map<String, dynamic> map, {String id = ""}) {
    return Request(
      id : id,
      donorId: map['donorId'],
      hospitalId: map['hospitalId'],
      bloodBankName: map['bloodBankName'],
      bloodBankId: map['bloodBankId'],
      bloodType: map['bloodType'],
      units: map['units'],
      date: map['date'],
      time: map['time'],
      reqStatus:map['reqStatus'],
      urgency: map['urgency'],
      reqSender: map['reqSender'],
      hospitalName: map['hospitalName'],
      donorsAcceptedCriticalReqNum: map['donorsAcceptedCriticalReqNum'],
    );
  }

  Request copyWith({
    String? donorId,
    String? hospitalId,
    String? bloodBankName,
    String? bloodBankId,
    String? bloodType,
    int? units,
    String? date,
    String? time,
    String? reqStatus,
    String? urgency,
    String? reqSender,
    String? hospitalName,
    int? donorsAcceptedCriticalReqNum,
  }) {
    return Request(
      donorId: donorId ?? this.donorId,
      hospitalId: hospitalId ?? this.hospitalId,
      bloodBankName: bloodBankName ?? this.bloodBankName,
      bloodBankId: bloodBankId ?? this.bloodBankId,
      bloodType: bloodType ?? this.bloodType,
      units: units ?? this.units,
      date: date ?? this.date,
      time: time ?? this.time,
      reqStatus: reqStatus ?? this.reqStatus,
      urgency: urgency ?? this.urgency,
      reqSender: reqSender ?? this.reqSender,
      hospitalName: hospitalName ?? this.hospitalName,
      donorsAcceptedCriticalReqNum : donorsAcceptedCriticalReqNum ?? this.donorsAcceptedCriticalReqNum,
    );
  }
}