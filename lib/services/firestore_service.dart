import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alarm.dart';

/// Handles all CRUD operations for the `alarms` collection.
///
/// Security rules (see README) restrict reads/writes to documents where
/// `userId` matches the caller's auth uid, so every query here is already
/// scoped per-user.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alarms =>
      _db.collection('alarms');

  /// Streams the live list of alarms belonging to [userId].
  Stream<List<Alarm>> watchAlarms(String userId) {
    return _alarms
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Alarm.fromFirestore).toList());
  }

  Future<Alarm> createAlarm(Alarm alarm) async {
    final ref = await _alarms.add(alarm.toFirestore());
    final doc = await ref.get();
    return Alarm.fromFirestore(doc);
  }

  Future<void> updateAlarm(Alarm alarm) {
    return _alarms.doc(alarm.id).update(alarm.toFirestore());
  }

  Future<void> deleteAlarm(String alarmId) {
    return _alarms.doc(alarmId).delete();
  }

  Future<void> setActive(String alarmId, bool isActive) {
    return _alarms.doc(alarmId).update({'isActive': isActive});
  }
}