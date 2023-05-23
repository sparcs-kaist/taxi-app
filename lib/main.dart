import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taxiapp/utils/pushHandler.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:taxiapp/views/taxiView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/firebase_options.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  channel = const AndroidNotificationChannel(
    'taxi_channel',
    'taxi_notification',
    description: 'This channel is used for taxi notifications',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(handleMessage);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );

  // 사용자가 푸시 알림을 허용했는지 확인 후 권한요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );
  await Token().init();
  runApp(MyHome());
}

class MyHome extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
        color: const Color(0xFF6E3647),
        child: Container(
          color: Colors.white,
          child: TaxiView(),
        ),
      ),
    );
  }
}
