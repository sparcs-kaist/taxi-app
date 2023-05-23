import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:math';

@pragma('vm:entry-point')
Future<void> handleMessage(RemoteMessage message) async {
  var channel = const AndroidNotificationChannel(
    'taxi_channel',
    'taxi_notification',
    description: 'This channel is used for taxi notifications',
    importance: Importance.high,
  );

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ByteArrayAndroidBitmap? largeIcon;

  if (message.data['icon'] != null) {
    largeIcon = ByteArrayAndroidBitmap(
      await _getByteArrayFromUrl(message.data['icon']),
    );
  }
  var androidNotiDetails = AndroidNotificationDetails(channel.id, channel.name,
      channelDescription: channel.description, largeIcon: largeIcon);

  var iOSNotiDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
  );

  var details =
      NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);

  if (message.data != null) {
    flutterLocalNotificationsPlugin.show(Random().nextInt(100000000),
        message.data['title'], message.data['body'], details,
        payload: message.data['url']);
  }
}

Future<Uint8List> _getByteArrayFromUrl(String url) async {
  final http.Response response = await http.get(Uri.parse(url));
  return response.bodyBytes;
}
