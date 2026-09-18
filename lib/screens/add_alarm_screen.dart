import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../services/auth_service.dart';

/// Lets the user tap a spot on the map, name it, and choose a trigger radius.
///
/// TODO: replace the placeholder container below with a GoogleMap widget
/// (see google_maps_flutter) and capture the tapped LatLng into
/// _selectedLat / _selectedLng.
class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  final _nameController = TextEditingController();
  double _radiusMeters = 150;
  double? _selectedLat;
  double? _selectedLng;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null || _selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a location on the map first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final alarm = Alarm(
      id: const Uuid().v4(),
      userId: userId,
      name: _nameController.text.trim().isEmpty
          ? 'Unnamed alarm'
          : _nameController.text.trim(),
      latitude: _selectedLat!,
      longitude: _selectedLng!,
      radiusMeters: _radiusMeters,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await context.read<AlarmProvider>().addAlarm(alarm);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO: swap for GoogleMap(onTap: ...) once google_maps_flutter
            // is configured with an API key.
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Text('Map picker goes here'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Alarm name'),
            ),
            const SizedBox(height: 16),
            Text('Trigger radius: ${_radiusMeters.toStringAsFixed(0)} m'),
            Slider(
              value: _radiusMeters,
              min: 50,
              max: 1000,
              divisions: 19,
              onChanged: (v) => setState(() => _radiusMeters = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save alarm'),
            ),
          ],
        ),
      ),
    );
  }
}