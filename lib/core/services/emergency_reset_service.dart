import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:www/core/models/blood_request.dart';

class EmergencyResetService {
  static const Duration _window = Duration(hours: 6);

  /// Called lazily whenever any user opens the app (via any wrapper's initState).
  /// Queries all critical+approved requests and resets those older than 6 hours
  /// back to pending so they get re-broadcast to all users.
  static Future<void> checkAndResetExpiredCriticalRequests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Request.collectionName)
          .where('urgency', isEqualTo: Urgency.critical.name)
          .where('reqStatus', isEqualTo: RequestStatus.approved.name)
          .get();

      final now = DateTime.now();
      final batch = FirebaseFirestore.instance.batch();
      bool hasPendingWrites = false;

      for (final doc in snapshot.docs) {
        final approvedAtRaw = doc.data()['approvedAt'];
        if (approvedAtRaw == null) continue;

        final approvedAt = DateTime.tryParse(approvedAtRaw as String);
        if (approvedAt == null) continue;

        if (now.difference(approvedAt) >= _window) {
          // Reset to pending and clear approval metadata
          batch.update(doc.reference, {
            'reqStatus': RequestStatus.pending.name,
            'approvedAt': null,
            'bloodBankId': null,
            'bloodBankName': null,
          });
          hasPendingWrites = true;
        }
      }

      if (hasPendingWrites) {
        await batch.commit();
      }
    } catch (_) {
      // Swallow silently — this is a background cleanup task.
      // Failures are non-critical and will retry on the next app open.
    }
  }

  /// Returns the remaining time in the 6-hour window for a given approvedAt string.
  /// Returns null if the request is not in the countdown window.
  static Duration? remainingTime(String? approvedAt) {
    if (approvedAt == null) return null;
    final approved = DateTime.tryParse(approvedAt);
    if (approved == null) return null;
    final elapsed = DateTime.now().difference(approved);
    if (elapsed >= _window) return Duration.zero;
    return _window - elapsed;
  }

  /// Formats a Duration into a human-readable string e.g. "4h 32m"
  static String formatCountdown(Duration d) {
    if (d <= Duration.zero) return 'Expired';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m remaining';
    return '${minutes}m remaining';
  }
}
