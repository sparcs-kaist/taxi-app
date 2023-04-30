import 'dart:async';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isTimerUp = useState(false);
    final isServerError = useState(false);

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
            Uri new_uri = Uri.parse(address)
                .replace(path: details.notificationResponse!.payload!);
            url.value = new_uri.toString();
            LoadCount.value != 1;
          }
        }
      });

      FirebaseDynamicLinks.instance.getInitialLink().then((initalLink) {
        if (initalLink != null) {
          url.value = initalLink.link.toString();
          LoadCount.value += 1;
        }
      });

      FirebaseDynamicLinks.instance.onLink.listen((event) {
        if (event != null) {
          url.value = event.link.toString();
          LoadCount.value += 1;
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
          await remoteConfig.setDefaults(
              {"version": value.version, "ios_version": value.version});
          await remoteConfig.fetchAndActivate();
          if (Platform.isIOS) {
            if (int.parse(
                    remoteConfig.getString("ios_version").replaceAll(".", "")) >
                int.parse(value.version.replaceAll(".", ""))) {
              isMustUpdate.value = true;
            }
          } else {
            if (int.parse(
                    remoteConfig.getString("version").replaceAll(".", "")) >
                int.parse(value.version.replaceAll(".", ""))) {
              isMustUpdate.value = true;
            }
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: "버전 체크에 실패했습니다.",
            backgroundColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      });
    }, []);

    useEffect(() {
      if (isAuthLogin.value && !isLogin.value) {
        Token().getSession().then((value) async {
          if (value == null) {
            if (Token().accessToken != '') {
              await Token().deleteAll();
            }
            isLogin.value = false;
            isAuthLogin.value = false;
          } else {
            sessionToken.value = value;
            isLogin.value = true;
            try {
              await _controller.value!.reload();
            } catch (e) {
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
      Timer(const Duration(seconds: 1), () {
        isTimerUp.value = true;
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
                    crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: true,
                        resourceCustomSchemes: ['intent']),
                    android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                        overScrollMode:
                            AndroidOverScrollMode.OVER_SCROLL_NEVER)),
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
                          await _cookieManager.deleteAllCookies();
                          await _controller.value!.loadUrl(
                              urlRequest: URLRequest(url: Uri.parse(address)));
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
                        } else {
                          openAppSettings();
                          Fluttertoast.showToast(
                            msg: "알림 권한을 허용해주세요.",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                          return false;
                        }
                      });

                  _controller.value?.addJavaScriptHandler(
                      handlerName: "clipboard_copy",
                      callback: (args) async {
                        if (Platform.isAndroid) {
                          await Clipboard.setData(ClipboardData(text: args[0]));
                          Fluttertoast.showToast(
                            msg: "클립보드에 복사되었습니다.",
                            toastLength: Toast.LENGTH_SHORT,
                          );
                        }
                      });
                },
                onLoadStart: (controller, uri) async {
                  if (isLogin.value &&
                      sessionToken.value != '' &&
                      uri?.origin == Uri.parse(address).origin &&
                      (await _cookieManager.getCookie(
                                  url: Uri.parse(address), name: "connect.sid"))
                              ?.value !=
                          sessionToken.value) {
                    try {
                      await _controller.value?.stopLoading();
                      await _cookieManager.deleteCookie(
                          url: Uri.parse(address), name: "connect.sid");
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
                      await _controller.value?.reload();
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
                onUpdateVisitedHistory:
                    (controller, url, androidIsReload) async {
                  // 로그아웃 링크 감지
                  if (url.toString().contains("logout") && isAuthLogin.value) {
                    await controller.stopLoading();
                    try {
                      await FcmToken().removeToken(Token().getAccessToken());
                      await Token().deleteAll();
                      isLogin.value = false;
                      isAuthLogin.value = false;
                      await _cookieManager.deleteAllCookies();
                      await _controller.value!.loadUrl(
                          urlRequest: URLRequest(url: Uri.parse(address)));
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
                onLoadResourceCustomScheme: (controller, url) async {
                  if (Platform.isAndroid) {
                    if (url.scheme == 'intent') {
                      try {
                        await controller.stopLoading();
                        const MethodChannel channel =
                            MethodChannel('org.sparcs.taxi_app/taxi_only');
                        final result = await channel.invokeMethod(
                            "launchURI", url.toString());
                        if (result != null) {
                          await _controller.value?.loadUrl(
                              urlRequest: URLRequest(url: Uri.parse(result)));
                        }
                      } catch (e) {
                        // TODO
                        await Fluttertoast.showToast(
                          msg: "카카오톡을 실행할 수 없습니다.",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      }
                    }
                  }
                  return null;
                },
                onLoadError: (controller, url, code, message) {
                  if (code == -2) {
                    Fluttertoast.showToast(
                      msg: "서버와의 연결에 실패했습니다.",
                      toastLength: Toast.LENGTH_SHORT,
                    );
                    isServerError.value = true;
                  }
                },
                onLoadStop: (finish, uri) async {
                  if (!isServerError.value) {
                    isLoaded.value = true;
                  }
                  if (uri
                          .toString()
                          .contains("sparcssso.kaist.ac.kr/account/login") &&
                      !address.contains("dev")) {
                    await _controller.value!.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('btn-kaist')?.[0]?.click()");
                  }
                }),
          )),
      isTimerUp.value && isLoaded.value
          ? Stack()
          : Scaffold(
              body: FadeTransition(opacity: animation, child: loadingView())),
      isMustUpdate.value
          ? Container(
              color: const Color(0x66C8C8C8),
              child: Center(
                  child: TaxiDialog(
                boxContent: {
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "새로운 ",
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFF323232),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        children: const <TextSpan>[
                          TextSpan(text: "버전"),
                          TextSpan(
                              text: "이 ",
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text: "출시",
                              style: TextStyle(color: Color(0xFF6E3678))),
                          TextSpan(
                              text: "되었습니다!",
                              style: TextStyle(fontWeight: FontWeight.normal))
                        ]),
                  ),
                  Text("정상적인 사용을 위해 앱을 업데이트 해주세요.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                              fontWeight: FontWeight.bold))),
                },
                rightButtonContent: "업데이트 하러가기",
                leftButtonContent: "앱 종료하기",
              )),
            )
          : Stack(),
      isServerError.value
          ? Container(
              color: const Color(0x66C8C8C8),
              child: Center(
                  child: TaxiDialog(
                boxContent: {
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "서버",
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFF323232),
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        children: const <TextSpan>[
                          TextSpan(text: "와의 "),
                          TextSpan(
                              text: "연결에 ",
                              style: TextStyle(fontWeight: FontWeight.normal)),
                          TextSpan(
                              text: "실패",
                              style: TextStyle(color: Color(0xFF6E3678))),
                          TextSpan(
                              text: "했습니다.",
                              style: TextStyle(fontWeight: FontWeight.normal))
                        ]),
                  ),
                  Padding(padding: EdgeInsets.only(top: 5)),
                  Text("일시적인 오류일 수 있습니다.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                              fontWeight: FontWeight.bold))),
                },
                rightButtonContent: "스토어로 가기",
                leftButtonContent: "앱 종료하기",
              )),
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
    String address = dotenv.get("FRONT_ADDRESS");
    if (await _controller.canGoBack() &&
        (current_uri?.path != '/') &&
        (current_uri?.path != '/home')) {
      _controller.goBack();
      backCount.value = false;
      return false;
    } else if (Uri.parse(address).origin != current_uri?.origin) {
      await _controller.loadUrl(
          urlRequest: URLRequest(url: Uri.parse(address)));
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
