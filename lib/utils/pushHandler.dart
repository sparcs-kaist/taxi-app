import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:taxiapp/views/taxiView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

@pragma('vm:entry-point')
Future<void> handleMessage(RemoteMessage message) async {
  var channel = const AndroidNotificationChannel(
    'taxi_channel',
    'taxi_notification',
    description: 'This channel is used for taxi notifications',
    importance: Importance.high,
  );

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  print("BACKGROUND SERVICE RUNNED!");
  print(message.toMap());

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  ByteArrayAndroidBitmap? largeIcon;

  if (android?.imageUrl != null) {
    largeIcon = ByteArrayAndroidBitmap(
      await _getByteArrayFromUrl(android!.imageUrl!),
    );
  }
  var androidNotiDetails = AndroidNotificationDetails(channel.id, channel.name,
      channelDescription: channel.description, largeIcon: largeIcon);

  var iOSNotiDetails = const DarwinNotificationDetails();

  var details =
      NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);

  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode, notification.title, notification.body, details,
        payload: message.data['url']);
  }
}

Future<Uint8List> _getByteArrayFromUrl(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}
