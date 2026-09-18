
/// Registers saved [Alarm]s as geofences and fires a local notification
/// when the device enters one.
///
/// TODO: this needs to run even when the app is fully closed. Follow the
/// geofence_service package's background-service setup for Android
/// (foreground service) and confirm behavior on iOS, where background
/// location is far more restricted.
class AppGeofenceService {
  final gfs.GeofenceService _service = gfs.GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    allowMockLocations: false,
    printDevLog: false,
  );

  final NotificationService _notifications;

  AppGeofenceService({NotificationService? notifications})
      : _notifications = notifications ?? NotificationService();

  /// Converts saved alarms into geofence_service geofences and starts
  /// monitoring. Call this on app start (if alarms exist) and whenever
  /// the alarm list changes.
  Future<void> syncGeofences(List<Alarm> alarms) async {
    _service.clearGeofenceList();

    for (final alarm in alarms.where((a) => a.isActive)) {
      _service.addGeofence(
        gfs.Geofence(
          id: alarm.id,
          latitude: alarm.latitude,
          longitude: alarm.longitude,
          radius: [
            gfs.GeofenceRadius(id: 'radius_${alarm.id}', length: alarm.radiusMeters),
          ],
        ),
      );
    }

    _service.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);

    try {
      await _service.start();
    } catch (_) {
      // TODO: surface a user-facing error if geofencing fails to start
      // (e.g. permissions revoked).
    }
  }

  Future<void> _onGeofenceStatusChanged(
      gfs.Geofence geofence,
      gfs.GeofenceRadius radius,
      gfs.GeofenceStatus status,
      gfs.Location location,
      ) async {
    if (status == gfs.GeofenceStatus.ENTER) {
      await _notifications.showArrivalNotification(
        id: geofence.id.hashCode,
        alarmName: geofence.id, // TODO: map id back to Alarm.name.
      );
    }
  }

  void dispose() {
    _service.clearGeofenceList();
  }
}