import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info/package_info.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/utils/pushHandler.dart';
import 'package:taxiapp/views/loadingView.dart';
import 'package:taxiapp/views/loginView.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:taxiapp/views/taxiDialog.dart';

class TaxiView extends HookWidget {
  Uri? url = null;
  final CookieManager _cookieManager = CookieManager.instance();
  // late InAppWebViewController _controller;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TaxiView({url});

  TaxiView({url});

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
              Fluttertoast.showToast(
                msg: "초기 페이지 로딩에 실패했습니다.",
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
                },
                // React Link는 Page를 로드하는 것이 아니라 history를 바꾸는 것이기 때문에 history 변화로 링크 변화를 감지해야함.
                onUpdateVisitedHistory:
                    (controller, url, androidIsReload) async {
                  // 세션이 만료되어 로그인 페이지로 돌아갈 시 자동으로 세션 갱신
                  if (url.toString().contains("login") &&
                      isLogin.value &&
                      isAuthLogin.value) {
                    try {
                      String? session = await Token().getSession();
                      if (session == null) {
                        isLogin.value = false;
                        isAuthLogin.value = false;
                      } else {
                        sessionToken.value = session;
                        await _controller.value!.loadUrl(
                            urlRequest: URLRequest(url: Uri.parse(address)));
                      }
                    } catch (e) {
                      // TODO handle error
                      Fluttertoast.showToast(
                        msg: "서버와의 연결에 실패했습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                      isAuthLogin.value = false;
                    }
                  }
                  // 로그아웃 감지 시 토큰 지우고 처음 로그인 페이지로 돌아가기
                  if (url.toString().contains("logout") && isLogin.value) {
                    try {
                      await FcmToken().removeToken(Token().getAccessToken());
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
                  }
                },
                onLoadStart: (controller, uri) async {
                  _controller.value = controller;
                  if (sessionToken.value != '') {
                    try {
                      await _cookieManager.deleteAllCookies();
                      await _cookieManager.setCookie(
                        url: Uri.parse(address),
                        name: "connect.sid",
                        value: sessionToken.value,
                      );
                      await _cookieManager.setCookie(
                        url: Uri.parse(address),
                        name: "deviceToken",
                        value: FcmToken().fcmToken,
                      );
                    } catch (e) {
                      // TODO : handle error
                      Fluttertoast.showToast(
                        msg: "서버와의 연결에 실패했습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                      isAuthLogin.value = false;
                    }
                  }
                },
                onLoadStop: (finish, uri) async {}),
          )),
      isAuthLogin.value ? Stack() : LoginView(isAuthLogin),
      isLoaded.value
          ? Stack()
          : Scaffold(
              body: FadeTransition(opacity: animation, child: loadingView())),
      isMustUpdate.value
          ? Container(
              color: Color(0x66C8C8C8),
              child: Center(child: TaxiDialog()),
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
        isAuthLogin.value &&
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
