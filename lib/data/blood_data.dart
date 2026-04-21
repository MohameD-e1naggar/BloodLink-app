import 'package:flutter/material.dart';

// تعريف كلاس البيانات هنا
class BloodRequest {
  final String bloodType;
  final String status;
  final String distance;
  final String details;
  final Color themeColor;

  BloodRequest({
    required this.bloodType,
    required this.status,
    required this.distance,
    required this.details,
    required this.themeColor,
  });
}

// القائمة فاضية - الطلبات بتيجي من allRequests في requests_store.dart
final List<BloodRequest> globalUrgentRequests = [];
