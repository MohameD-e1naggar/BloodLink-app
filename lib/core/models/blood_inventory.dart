class Inventory {
  static const String collectionName = "inventory";

  final int? aPos;
  final int? bPos;
  final int? oPos;
  final int? abPos;
  final int? aNeg;
  final int? bNeg;
  final int? oNeg;
  final int? abNeg;

  Inventory({
    this.aPos,
    this.bPos,
    this.oPos,
    this.abPos,
    this.aNeg,
    this.bNeg,
    this.oNeg,
    this.abNeg,
  });

  Map<String, dynamic> toMap() {
    return {
      'A+': aPos,
      'B+': bPos,
      'O+': oPos,
      'AB+': abPos,
      'A-': aNeg,
      'B-': bNeg,
      'O-': oNeg,
      'AB-': abNeg,
    };
  }

  factory Inventory.fromMap(Map<String, dynamic>? map) {
    return Inventory(
      aPos: map?['A+'],
      bPos: map?['B+'],
      oPos: map?['O+'],
      abPos: map?['AB+'],
      aNeg: map?['A-'],
      bNeg: map?['B-'],
      oNeg: map?['O-'],
      abNeg: map?['AB-'],
    );
  }

  Inventory copyWith({
    int? aPos,
    int? bPos,
    int? oPos,
    int? abPos,
    int? aNeg,
    int? bNeg,
    int? oNeg,
    int? abNeg,
  }) {
    return Inventory(
      aPos: aPos ?? this.aPos,
      bPos: bPos ?? this.bPos,
      oPos: oPos ?? this.oPos,
      abPos: abPos ?? this.abPos,
      aNeg: aNeg ?? this.aNeg,
      bNeg: bNeg ?? this.bNeg,
      oNeg: oNeg ?? this.oNeg,
      abNeg: abNeg ?? this.abNeg,
    );
  }

  Map<String, int> toBloodMap() {
    return {
      'A+': aPos ?? 0,
      'A-': aNeg ?? 0,
      'B+': bPos ?? 0,
      'B-': bNeg ?? 0,
      'O+': oPos ?? 0,
      'O-': oNeg ?? 0,
      'AB+': abPos ?? 0,
      'AB-': abNeg ?? 0,
    };
  }
}