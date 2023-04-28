import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/utils/pushHandler.dart';
import 'package:taxiapp/views/loadingView.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:taxiapp/views/taxiDialog.dart';

class TaxiView extends HookWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  // late InAppWebViewController _controller;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    final isLoaded = useState(false);
    final sessionToken = useState('');
    final isLogin = useState(false);
    final isAuthLogin = useState(true);
    final backCount = useState(false);
    final LoadCount = useState(0);
    final url = useState('');
    final _controller = useRef<InAppWebViewController?>(null);
    final isMustUpdate = useState(false);

    useEffect(() {
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (message.data['url'] != null) {
          if (message.data['url'] ==
              (await _controller.value!.getUrl())
                  ?.path
                  .replaceAll("chatting", "myroom")) {
            return;
          } else {
            handleMessage(message);
          }
        }
      });

      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            String address = dotenv.get("FRONT_ADDRESS");
            url.value = address + details.payload!;
            LoadCount.value += 1;
          }
        },
      );

      flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails()
          .then((NotificationAppLaunchDetails? details) {
        if (details != null) {
          if (details.didNotificationLaunchApp &&
              details.notificationResponse?.payload != null) {
            String address = dotenv.get("FRONT_ADDRESS");
            url.value = address + details.notificationResponse!.payload!;
            LoadCount.value != 1;
          }
        }
      });
    }, []);

    useEffect(() {
      if (url.value != '') {
        _controller.value!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse(url.value)))
            .then((value) {});
      }
    }, [LoadCount.value]);

    final AnimationController aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> animation = CurvedAnimation(
      parent: aniController,
      curve: Curves.easeIn,
    );
    String address = dotenv.get("FRONT_ADDRESS");

    useEffect(() {
      PackageInfo.fromPlatform().then((value) async {
        final remoteConfig = FirebaseRemoteConfig.instance;
        try {
          await remoteConfig.setConfigSettings(RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: Duration.zero,
          ));
          await remoteConfig.setDefaults({"version": value.version});
          await remoteConfig.fetchAndActivate();
          if (remoteConfig.getString("version") != value.version) {
            isMustUpdate.value = true;
          }
        } catch (e) {
          print(e);
        }
      });
    }, []);

    useEffect(() {
      if (isAuthLogin.value && !isLogin.value) {
        Token().getSession().then((value) async {
          if (value == null) {
            isLogin.value = false;
            isAuthLogin.value = false;
          } else {
            sessionToken.value = value;
            isLogin.value = true;
            try {
              await _controller.value!
                  .loadUrl(urlRequest: URLRequest(url: Uri.parse(address)));
            } catch (e) {
              print(e);
              Fluttertoast.showToast(
                msg: "로그인에 실패했습니다.",
                backgroundColor: Colors.white,
                toastLength: Toast.LENGTH_SHORT,
              );
            }
          }
        });
      }
      return;
    }, [isAuthLogin.value]);

    useEffect(() {
      Timer(const Duration(seconds: 2), () {
        isLoaded.value = true;
      });
      return;
    }, []);
    return SafeArea(
        child: Stack(children: [
      WillPopScope(
          onWillPop: () =>
              _goBack(context, backCount, isAuthLogin, _controller.value),
          child: Scaffold(
            body: InAppWebView(
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform:
                        InAppWebViewOptions(useShouldOverrideUrlLoading: true),
                    android:
                        AndroidInAppWebViewOptions(useHybridComposition: true)),
                initialUrlRequest: URLRequest(url: Uri.parse(address)),
                onWebViewCreated: (InAppWebViewController webcontroller) async {
                  _controller.value = webcontroller;
                  _controller.value?.addJavaScriptHandler(
                    handlerName: "auth_update",
                    callback: (arguments) async {
                      if (arguments == [{}]) {
                        isLogin.value = false;
                        return;
                      }
                      if (!isAuthLogin.value) {
                        await Token().setAccessToken(
                            accessToken: arguments[0]['accessToken']);
                        await Token().setRefreshToken(
                            refreshToken: arguments[0]['refreshToken']);
                        await FcmToken()
                            .registerToken(arguments[0]['accessToken']);
                        isAuthLogin.value = true;
                      }
                      return;
                    },
                  );
                  _controller.value?.addJavaScriptHandler(
                      handlerName: "auth_logout",
                      callback: (args) async {
                        try {
                          await FcmToken()
                              .removeToken(Token().getAccessToken());
                          await Token().deleteAll();
                          isLogin.value = false;
                          isAuthLogin.value = false;
                        } catch (e) {
                          // TODO
                          Fluttertoast.showToast(
                            msg: "서버와의 연결에 실패했습니다.",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                          isAuthLogin.value = false;
                        }
                      });

                  _controller.value?.addJavaScriptHandler(
                      handlerName: "try_notification",
                      callback: (args) async {
                        if (await Permission.notification.isGranted) {
                          return true;
                        } else if (await Permission
                            .notification.isPermanentlyDenied) {
                          openAppSettings();
                          Fluttertoast.showToast(
                            msg: "알림 권한을 허용해주세요.",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                          return false;
                        } else {
                          await FirebaseMessaging.instance.requestPermission(
                            alert: true,
                            announcement: false,
                            badge: true,
                            carPlay: false,
                            criticalAlert: false,
                            provisional: false,
                            sound: true,
                          );
                          if (await Permission.notification.isGranted) {
                            return true;
                          } else {
                            return false;
                          }
                        }
                      });
                },
                onLoadStop: (finish, uri) async {}),
          )),
      isLoaded.value
          ? Stack()
          : Scaffold(
              body: FadeTransition(opacity: animation, child: loadingView())),
      isMustUpdate.value
          ? Container(
              color: const Color(0x66C8C8C8),
              child: const Center(child: TaxiDialog()),
            )
          : Stack()
    ]));
  }

  Future<bool> _goBack(
      BuildContext context,
      ValueNotifier<bool> backCount,
      ValueNotifier<bool> isAuthLogin,
      InAppWebViewController? _controller) async {
    Uri? current_uri = await _controller!.getUrl();
    if (await _controller.canGoBack() &&
        (current_uri?.path != '/') &&
        (current_uri?.path != '/home')) {
      _controller.goBack();
      backCount.value = false;
      return false;
    } else if (backCount.value) {
      return true;
    } else {
      backCount.value = true;
      Fluttertoast.showToast(
        msg: "한번 더 누르시면 앱을 종료합니다.",
        backgroundColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }
}
