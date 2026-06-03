import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationScreen({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {

          final notif = notifications[index];

          return ListTile(
            leading: const Icon(
              Icons.notifications_active,
              color: Colors.green,
            ),
            title: Text(notif.title),
            subtitle: Text(notif.message),
            trailing: Text(
              notif.time,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          );
        },
      ),
    );
  }
}