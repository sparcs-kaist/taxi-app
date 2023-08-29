import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';
import 'package:taxiapp/utils/pushHandler.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:taxiapp/views/taxiView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/firebase_options.dart';
import 'constants/theme.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 모든 에러 전송
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  // await Future.delayed(Duration(seconds: 5));

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

  await Token().init();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: true,
    sound: true,
  );

  await RemoteConfigController().init();

  runApp(MyHome());
}

class MyHome extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxi App',
      theme: buildTheme(),
      home: Container(
        color: Theme.of(context).primaryColor,
        child: Container(
          color: Colors.white,
          child: TaxiView(),
        ),
      ),
    );
  }
}
