import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alarm.dart';
import '../providers/alarm_provider.dart';

class AlarmDetailScreen extends StatefulWidget {
  final Alarm alarm;

  const AlarmDetailScreen({super.key, required this.alarm});

  @override
  State<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends State<AlarmDetailScreen> {
  late final TextEditingController _nameController;
  late double _radiusMeters;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.alarm.name);
    _radiusMeters = widget.alarm.radiusMeters;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updated = widget.alarm.copyWith(
      name: _nameController.text.trim(),
      radiusMeters: _radiusMeters,
    );
    await context.read<AlarmProvider>().updateAlarm(updated);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete alarm?'),
        content: Text('This will remove "${widget.alarm.name}" permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AlarmProvider>().deleteAlarm(widget.alarm.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Details'),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _confirmDelete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            // TODO: show a small static map preview of the saved location.
            FilledButton(
              onPressed: _saveChanges,
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}