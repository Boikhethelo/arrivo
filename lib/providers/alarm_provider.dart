import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/alarm.dart';
import '../services/firestore_service.dart';

/// App-wide alarm state, backed by a live Firestore stream.
class AlarmProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  StreamSubscription<List<Alarm>>? _subscription;
  List<Alarm> _alarms = [];
  bool _isLoading = false;

  AlarmProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  List<Alarm> get alarms => List.unmodifiable(_alarms);
  bool get isLoading => _isLoading;

  /// Starts listening to Firestore for the given user. Call on login.
  void listenTo(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.watchAlarms(userId).listen((alarms) {
      _alarms = alarms;
      _isLoading = false;
      notifyListeners();
      // TODO: re-sync geofences with AppGeofenceService whenever this fires.
    });
  }

  /// Stops listening. Call on logout.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _alarms = [];
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) => _firestoreService.createAlarm(alarm);

  Future<void> updateAlarm(Alarm alarm) =>
      _firestoreService.updateAlarm(alarm);

  Future<void> deleteAlarm(String alarmId) =>
      _firestoreService.deleteAlarm(alarmId);

  Future<void> toggleActive(String alarmId, bool isActive) =>
      _firestoreService.setActive(alarmId, isActive);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}