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

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

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
    alert: true,
    badge: true,
    sound: true,
  );

  // 사용자가 푸시 알림을 허용했는지 확인 후 권한요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await Token().init();

  await FcmToken().init();

  FirebaseMessaging.onMessage.listen(handleMessage);

  runApp(MyHome());
}

@pragma('vm:entry-point')
Future<void> handleMessage(RemoteMessage message) async {
  channel = const AndroidNotificationChannel(
    'taxi_channel',
    'taxi_notification',
    description: 'This channel is used for taxi notifications',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

class MyHome extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final url = useState('');

    useEffect(() {
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');

      var initializationSettingsIOS = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          print("onReceive Payload ${details.payload}");
          if (details.payload != null) {
            url.value = details.payload!;
            print("SET STATE CALLED! ${url.value}");
          }
        },
      );

      flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails()
          .then((NotificationAppLaunchDetails? details) {
        if (details != null) {
          if (details.didNotificationLaunchApp &&
              details.notificationResponse?.payload != null) {
            url.value = details.notificationResponse!.payload!;
          }
        }
      });
    }, []);

    return MaterialApp(
      title: 'Taxi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
        color: const Color(0xFF6E3647),
        child: Container(
            color: Colors.white,
            child: TaxiView(
              init_uri: url.value == '' ? null : Uri.parse(url.value),
            )),
      ),
    );
  }
}

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String url = '';

//   @override
//   void initState() {
//     super.initState();

//     var initializationSettingsAndroid =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');

//     var initializationSettingsIOS = const DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         print("onReceive Payload ${details.payload}");
//         if (details.payload != null) {
//           url = details.payload!;
//           this.setState(() {
//             url = details.payload!;
//           });
//           print("SET STATE CALLED! ${this.url}");
//         }
//       },
//       onDidReceiveBackgroundNotificationResponse: (details) {
//         print("onTap Payload ${details.payload}");
//         if (details.payload != null) {
//           url = details.payload!;
//           this.setState(() {
//             url = details.payload!;
//           });
//         }
//       },
//     );

//     flutterLocalNotificationsPlugin
//         .getNotificationAppLaunchDetails()
//         .then((NotificationAppLaunchDetails? details) {
//       if (details != null) {
//         if (details.didNotificationLaunchApp &&
//             details.notificationResponse?.payload != null) {
//           url = details.notificationResponse!.payload!;
//           setState(() {
//             url = details.notificationResponse!.payload!;
//           });
//         }
//       }
//     });

//     // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     //   if (message.data['url'] != null) {
//     //     setState(() {
//     //       url = message.data['url'];
//     //     });
//     //   }
//     // });

//     // FirebaseMessaging.instance
//     //     .getInitialMessage()
//     //     .then((RemoteMessage? message) {
//     //   if (message != null) {
//     //     print('msg : ${message.toMap()}');

//     //     if (message.data['url'] != null) {
//     //       setState(() {
//     //         url = message.data['url'];
//     //       });
//     //     }
//     //   }
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("URL IS ${url}");

//     return MaterialApp(
//       title: 'Taxi App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Container(
//         color: const Color(0xFF6E3647),
//         child: Container(
//             color: Colors.white,
//             child: TaxiView(
//               init_uri: url == '' ? null : Uri.parse(url),
//             )),
//       ),
//     );
//   }
// }
