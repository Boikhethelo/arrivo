import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alarm_provider.dart';
import '../services/auth_service.dart';
import 'add_alarm_screen.dart';
import 'alarm_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alarmProvider = context.watch<AlarmProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Alarms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: alarmProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : alarmProvider.alarms.isEmpty
          ? const Center(child: Text('No alarms yet — tap + to add one.'))
          : ListView.builder(
        itemCount: alarmProvider.alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarmProvider.alarms[index];
          return ListTile(
            leading: Icon(
              alarm.isActive
                  ? Icons.location_on
                  : Icons.location_off_outlined,
            ),
            title: Text(alarm.name),
            subtitle: Text('${alarm.radiusMeters.toStringAsFixed(0)} m radius'),
            trailing: Switch(
              value: alarm.isActive,
              onChanged: (value) =>
                  alarmProvider.toggleActive(alarm.id, value),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AlarmDetailScreen(alarm: alarm),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddAlarmScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}