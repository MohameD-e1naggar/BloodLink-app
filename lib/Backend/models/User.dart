enum UserTypes{
  donor,
  hospital,
  bloodBank
}


class User {
  static const String collectionName = "User";
  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? donorDob;
  final String? donorGender;
  final String? bloodType;
  final String? weight;
  final bool? hasChronicDiseases;
  final bool? takesMedication;
  final bool? hadSurgery;
  final bool? hasAnemia;
  final String? donorLastDonation;
  final String? adminName;
  final String? adminPhoneNumber;
  final String? adminNationalId;
  final String? address;
  final String? workingHours;
  final String type;
  
  final List<String>? acceptedCriticalReqs;
  final List<String>? rejectedCriticalReqs;
  final List<String>? hiddenCriticalReqs;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.donorDob,
    this.donorGender,
    this.bloodType,
    this.weight,
    this.hasChronicDiseases,
    this.takesMedication,
    this.hadSurgery,
    this.hasAnemia,
    this.donorLastDonation,
    this.adminName,
    this.adminPhoneNumber,
    this.adminNationalId,
    this.address,
    this.workingHours,
    required this.type,
    this.acceptedCriticalReqs,
    this.rejectedCriticalReqs,
    this.hiddenCriticalReqs,
  });

  // Convert object → Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id ,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'donorDob': donorDob,
      'donorGender': donorGender,
      'bloodType': bloodType,
      'weight': weight,
      'hasChronicDiseases': hasChronicDiseases,
      'takesMedication': takesMedication,
      'hadSurgery': hadSurgery,
      'hasAnemia': hasAnemia,
      'donorLastDonation': donorLastDonation,
      'adminName': adminName,
      'adminPhoneNumber': adminPhoneNumber,
      'adminNationalId': adminNationalId,
      'address': address,
      'workingHours': workingHours,
      'type': type,
      'acceptedCriticalReqs': acceptedCriticalReqs ?? [],
      'rejectedCriticalReqs': rejectedCriticalReqs ?? [],
      'hiddenCriticalReqs': hiddenCriticalReqs ?? [],
    };
  }

  // Convert Firestore → object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      donorDob: map['donorDob'],
      donorGender: map['donorGender'],
      bloodType: map['bloodType'],
      weight: map['weight'],
      hasChronicDiseases: map['hasChronicDiseases'],
      takesMedication: map['takesMedication'],
      hadSurgery: map['hadSurgery'],
      hasAnemia: map['hasAnemia'],
      donorLastDonation: map['donorLastDonation'],
      adminName: map['adminName'],
      adminPhoneNumber: map['adminPhoneNumber'],
      adminNationalId: map['adminNationalId'],
      address: map['address'],
      workingHours: map['workingHours'],
      type: map['type'],
      acceptedCriticalReqs: map['acceptedCriticalReqs'] != null ? List<String>.from(map['acceptedCriticalReqs']) : [],
      rejectedCriticalReqs: map['rejectedCriticalReqs'] != null ? List<String>.from(map['rejectedCriticalReqs']) : [],
      hiddenCriticalReqs: map['hiddenCriticalReqs'] != null ? List<String>.from(map['hiddenCriticalReqs']) : [],
    );
  }

  // Optional: safer updates
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? donorDob,
    String? donorGender,
    String? bloodType,
    String? weight,
    bool? hasChronicDiseases,
    bool? takesMedication,
    bool? hadSurgery,
    bool? hasAnemia,
    String? donorLastDonation,
    String? adminName,
    String? adminPhoneNumber,
    String? adminNationalId,
    String? address,
    String? workingHours,
    String? type,
    List<String>? acceptedCriticalReqs,
    List<String>? rejectedCriticalReqs,
    List<String>? hiddenCriticalReqs,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      donorDob: donorDob ?? this.donorDob,
      donorGender: donorGender ?? this.donorGender,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      hasChronicDiseases: hasChronicDiseases ?? this.hasChronicDiseases,
      takesMedication: takesMedication ?? this.takesMedication,
      hadSurgery: hadSurgery ?? this.hadSurgery,
      hasAnemia: hasAnemia ?? this.hasAnemia,
      donorLastDonation: donorLastDonation ?? this.donorLastDonation,
      adminName: adminName ?? this.adminName,
      adminPhoneNumber: adminPhoneNumber ?? this.adminPhoneNumber,
      adminNationalId: adminNationalId ?? this.adminNationalId,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      type: type ?? this.type,
      acceptedCriticalReqs: acceptedCriticalReqs ?? this.acceptedCriticalReqs,
      rejectedCriticalReqs: rejectedCriticalReqs ?? this.rejectedCriticalReqs,
      hiddenCriticalReqs: hiddenCriticalReqs ?? this.hiddenCriticalReqs,
    );
  }
}