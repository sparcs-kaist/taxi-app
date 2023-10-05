import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_share/social_share.dart';
import 'package:taxiapp/constants/theme.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/utils/pushHandler.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';
import 'package:taxiapp/views/loadingView.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taxiapp/views/taxiDialog.dart';
import 'package:app_links/app_links.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:open_store/open_store.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:linear_timer/linear_timer.dart';

class TaxiView extends HookWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  // late InAppWebViewController _controller;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    String address = RemoteConfigController().frontUrl;
    OverlayEntry? overlayEntry;
    AnimationController _aniController =
        useAnimationController(duration: const Duration(milliseconds: 300));
    bool isBannerShow = false;

    // States
    // 로딩 여부 확인
    final isLoaded = useState(false);
    // 로그인 세션 정보
    final sessionToken = useState('');
    // 로그인 여부 확인
    final isLogin = useState(false);
    // 자동 로그인 여부 확인
    final isAuthLogin = useState(true);
    // 뒤로가기 2번 눌렀는 지 확인
    final backCount = useState(false);
    // URL 로딩을 위한 더미 변수
    final LoadCount = useState(0);
    // 최초로 로딩할 URL 값 + Firebase Dynamic Link or Messaging 통해 가져옴 / 기본 값은 홈페이지
    final url = useState(address);
    // 웹 뷰 컨트롤러
    final _controller = useRef<InAppWebViewController?>(null);
    // 업데이트 버전 체크 후 업데이트 창 노출 여부 확인
    final isMustUpdate = useState(false);
    // 타이머 종료 여부 확인
    final isTimerUp = useState(false);
    // 서버 에러 발생 여부 확인
    final isServerError = useState(false);
    // 로그인 페이지에서 로그인 성공 여부 확인 최초에만 실행
    final isFirstLogin = useState(true);
    // FCM init 여부 확인
    final isFcmInit = useState(false);

    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    useEffect(() {
      if (isTimerUp.value) {
        FcmToken().init().then((value) {
          isFcmInit.value = true;
        }).onError((error, stackTrace) async {
          await Future.delayed(Duration(seconds: 5));
          FcmToken().init().then((value) {
            isFcmInit.value = true;
          }).onError((error, stackTrace) {
            isServerError.value = true;
          });
        });
      }
    }, [isTimerUp.value]);

    // Firebase Messaging 설정 / Firebase Dynamic Link 설정
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

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['url'] != null) {
          Uri newUri = Uri.parse(RemoteConfigController().frontUrl)
              .replace(path: message.data['url']);
          url.value = newUri.toString();
          LoadCount.value += 1;
        }
      });

      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          if (message.data['url'] != null) {
            Uri newUri = Uri.parse(RemoteConfigController().frontUrl)
                .replace(path: message.data['url']);
            url.value = newUri.toString();
            LoadCount.value += 1;
          }
        }
      });

      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            url.value = RemoteConfigController().frontUrl + details.payload!;
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
            Uri new_uri = Uri.parse(address)
                .replace(path: details.notificationResponse!.payload!);
            url.value = new_uri.toString();
            LoadCount.value += 1;
          }
        }
      });

      FirebaseDynamicLinks.instance.onLink.listen((event) {
        url.value = event.link.toString();
        LoadCount.value += 1;
      });

      FirebaseDynamicLinks.instance.getInitialLink().then((initalLink) async {
        if (initalLink != null) {
          url.value = initalLink.link.toString();
          LoadCount.value += 1;
        } else {
          final _appLinks = AppLinks();
          final Uri? uri = await _appLinks.getInitialAppLink();
          if (uri != null) {
            final PendingDynamicLinkData? appLinkData =
                await FirebaseDynamicLinks.instance.getDynamicLink(uri);
            if (appLinkData != null) {
              url.value = appLinkData.link.toString();
              LoadCount.value += 1;
            }
          }
        }
      });
    }, []);

    // URL 로딩 부분 / LoadCount 값이 바뀔 때마다 실행
    useEffect(() {
      if (url.value != '' && _controller.value != null) {
        _controller.value!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse(url.value)))
            .then((value) {});
      }
    }, [LoadCount.value]);

    // 로딩 페이지 로고 애니메이션 & 시간 타이머
    final AnimationController aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> animation = CurvedAnimation(
      parent: aniController,
      curve: Curves.easeIn,
    );

    useEffect(() {
      Timer(const Duration(seconds: 1, milliseconds: 600), () {
        isTimerUp.value = true;
      });
      return;
    }, []);

    // 버전 업데이트 체크
    useEffect(() {
      PackageInfo.fromPlatform().then((value) async {
        try {
          if (Platform.isIOS) {
            if (int.parse(
                    RemoteConfigController().iosVersion.replaceAll(".", "")) >
                int.parse(value.version.replaceAll(".", ""))) {
              isMustUpdate.value = true;
            }
          } else {
            if (int.parse(RemoteConfigController()
                    .androidVersion
                    .replaceAll(".", "")) >
                int.parse(value.version.replaceAll(".", ""))) {
              isMustUpdate.value = true;
            }
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: "버전 체크에 실패했습니다. " + e.toString(),
            backgroundColor: toastBackgroundColor,
            toastLength: Toast.LENGTH_SHORT,
            textColor: toastTextColor,
          );
        }
      });
    }, []);

    // 로그인 정보 갱신
    useEffect(() {
      if (isAuthLogin.value && !isLogin.value && isFcmInit.value) {
        Token().getSession().then((value) async {
          if (value == null) {
            if (Token().accessToken != '') {
              await Token().deleteAll();
            }
            await _cookieManager.deleteCookie(
                url: Uri.parse(RemoteConfigController().backUrl),
                name: "connect.sid");
            isAuthLogin.value = false;
            isLogin.value = false;
            isFirstLogin.value = false;
            LoadCount.value += 1;
          } else {
            FcmToken().registerToken(Token().accessToken);
            sessionToken.value = value;
            isLogin.value = true;
            try {
              if (isFirstLogin.value) {
                LoadCount.value += 1;
                isFirstLogin.value = false;
              } else {
                url.value = address;
                LoadCount.value += 1;
              }
            } catch (e) {
              Fluttertoast.showToast(
                msg: "로그인에 실패했습니다.",
                backgroundColor: toastBackgroundColor,
                toastLength: Toast.LENGTH_SHORT,
                textColor: toastTextColor,
              );
            }
          }
        });
      }
      return;
    }, [isAuthLogin.value, isFcmInit.value]);

    void removeOverlayNotification() {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    void removeAnimation() {
      _aniController.reverse(); //TODO: 일정 dy 미만시 배너 삭제 취소 및 애니메이션 다시 재생
      isBannerShow = false;
      // removeOverlayNotification();
    }

    void createOverlayNotification(
        {required String title,
        required String subTitle,
        required String content,
        Map<String, String> button = const {"": ""},
        Uri? imageUrl,
        required int type}) {
      if (overlayEntry != null) {
        removeOverlayNotification();
      }
      assert(overlayEntry == null);
      isBannerShow = true;

      double imageSize = 0;
      double imageBorderRadius = 0;
      double margin = 0;
      String webviewEventPushHistory = """
                                      window.dispatchEvent(new CustomEvent("pushHistory", {
                                        detail: "${button.values.first}"
                                        }));
                              """;
      if (type == 0) {
        //type: default
        imageSize = 50;
        imageBorderRadius = 12;
        margin = 20.0;
      } else if (type == 1) {
        //type: chat
        imageSize = 40;
        imageBorderRadius = 20;
        margin = 0.0;
      }

      overlayEntry = OverlayEntry(builder: (BuildContext context) {
        return SwipeableTile(
          color: Colors.white,
          swipeThreshold: 0.2,
          direction: SwipeDirection.horizontal,
          onSwiped: (direction) {
            removeOverlayNotification();
          },
          backgroundBuilder: (context, direction, progress) {
            if (direction == SwipeDirection.endToStart) {
              // return your widget
            } else if (direction == SwipeDirection.startToEnd) {
              // return your widget
            }
            return Container();
          },
          key: UniqueKey(),
          child: Stack(
            children: [
              // 상단 보라색 바
              Container(
                alignment: Alignment.topCenter,
                child: LinearTimer(
                  minHeight: 5,
                  color: taxiPrimaryColor,
                  duration: const Duration(seconds: 5),
                  onTimerEnd: () {
                    removeOverlayNotification();
                  },
                ),
              ),
              //image
              Positioned(
                  left: 20,
                  top: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageBorderRadius),
                    child: (imageSize != 0)
                        ? Image(
                            image: NetworkImage(imageUrl.toString()),
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                          )
                        : const Padding(padding: EdgeInsets.zero),
                  )),
              //title and subTitle
              Positioned(
                left: 20 + imageSize + margin, // 이미지 없을 시  마진 20으로 변경
                top: 20,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 10,
                            ),
                      ),
                      TextSpan(
                          text: (subTitle.isNotEmpty) ? "  /  $subTitle" : "",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontSize: 10, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              //본문
              Positioned(
                left: 20 + imageSize + margin,
                top: 40,
                width:
                    MediaQuery.of(context).size.width - 40 - imageSize + margin,
                child: Text(
                  content,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.4),
                ),
              ),
              //button
              (button.keys.first != "")
                  ? Positioned(
                      bottom: 15 / devicePixelRatio,
                      right: 15 / devicePixelRatio,
                      child: OutlinedButton(
                          style: defaultNotificatonOutlinedButtonStyle,
                          child: Text(
                            button.keys.first,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(fontSize: 12),
                          ),
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 300),
                                () async {
                              if (button.values.first != "") {
                                await _controller.value?.evaluateJavascript(
                                    source: webviewEventPushHistory);
                              }
                              removeOverlayNotification();
                            });
                          }),
                    )
                  : const Padding(padding: EdgeInsets.zero),
            ],
          ),
        );
      });
      Overlay.of(context).insert(overlayEntry!);
    }

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
                        applicationNameForUserAgent: "taxi-app-webview/" +
                            (Platform.isAndroid ? "android" : "ios"),
                        resourceCustomSchemes: [
                          'intent',
                          'supertoss',
                          'uber',
                          'tmoneyonda',
                          'kakaotalk',
                          'kakaot'
                        ]),
                    android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                        overScrollMode:
                            AndroidOverScrollMode.OVER_SCROLL_NEVER),
                    ios: IOSInAppWebViewOptions(disallowOverScroll: true)),
                // initialUrlRequest: URLRequest(url: Uri.parse(address)),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var newHeaders = Map<String, String>.from(
                      navigationAction.request.headers ?? {});
                  if (Platform.isAndroid &&
                      !newHeaders.containsKey("Referer") &&
                      navigationAction.request.url.toString() !=
                          'about:blank' &&
                      (navigationAction.request.url?.origin ==
                              Uri.parse(address).origin ||
                          navigationAction.request.url?.origin ==
                              Uri.parse(RemoteConfigController().backUrl)
                                  .origin)) {
                    newHeaders['Referer'] =
                        navigationAction.request.url.toString();
                    newHeaders['Origin'] = RemoteConfigController().frontUrl;
                    var newRequest = navigationAction.request;
                    newRequest.headers = newHeaders;
                    await controller.loadUrl(urlRequest: newRequest);

                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onWebViewCreated: (InAppWebViewController webcontroller) async {
                  _controller.value = webcontroller;
                  _controller.value?.addJavaScriptHandler(
                    handlerName: "auth_update",
                    callback: (arguments) async {
                      // 로그인 해제 시 로그인 State 변경
                      if (arguments == [{}]) {
                        isLogin.value = false;
                        return;
                      }
                      // 로그인 성공 시 / 기존 토큰 삭제 후 새로운 토큰 저장
                      if (!isAuthLogin.value) {
                        if (arguments[0]['accessToken'] != null &&
                            arguments[0]['refreshToken'] != null) {
                          await Token().deleteAll();
                          await Token().setAccessToken(
                              accessToken: arguments[0]['accessToken']);
                          await Token().setRefreshToken(
                              refreshToken: arguments[0]['refreshToken']);
                          await FcmToken()
                              .registerToken(arguments[0]['accessToken']);
                          isAuthLogin.value = true;
                        }
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
                          await _cookieManager.deleteAllCookies();
                          isLogin.value = false;
                          isAuthLogin.value = false;
                          await _controller.value?.loadUrl(
                              urlRequest: URLRequest(
                                  url: Uri.parse(RemoteConfigController()
                                      .frontUrl
                                      .toString())));
                        } catch (e) {
                          // TODO
                          Fluttertoast.showToast(
                              msg: "서버와의 연결에 실패했습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: toastTextColor,
                              backgroundColor: toastBackgroundColor);
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
                              textColor: toastTextColor,
                              backgroundColor: toastBackgroundColor);
                          return false;
                        }
                      });

                  _controller.value?.addJavaScriptHandler(
                      handlerName: "clipboard_copy",
                      callback: (args) async {
                        if (Platform.isAndroid) {
                          await Clipboard.setData(ClipboardData(text: args[0]));
                        }
                      });

                  // Web -> App
                  _controller.value?.addJavaScriptHandler(
                      handlerName: "popup_inAppNotification",
                      callback: (args) async {
                        try {
                          int types = 0;
                          switch (args[0]['type'].toString()) {
                            case "default":
                              types = 0;
                              break;
                            case "chat":
                              types = 1;
                              break;
                          }
                          createOverlayNotification(
                              title: args[0]['title'].toString(),
                              subTitle: args[0]['subtitle'].toString(),
                              content: args[0]['content'].toString(),
                              button: (args[0].containsKey("button"))
                                  ? {
                                      args[0]['button']['text'].toString():
                                          args[0]['button']['path'].toString()
                                    }
                                  : {"": ""},
                              type: types,
                              imageUrl: (args[0]['type'].toString() ==
                                      "default")
                                  ? Uri.parse(args[0]['imageUrl'].toString())
                                  : Uri.parse(
                                      args[0]['profileUrl'].toString()));
                        } on Exception catch (e) {
                          Fluttertoast.showToast(
                              msg: "인앱 알림 로드에 실패하였습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: toastTextColor,
                              backgroundColor: toastBackgroundColor);
                          return false;
                        }
                        return true;
                      });

                  _controller.value?.addJavaScriptHandler(
                      handlerName: "popup_instagram_story_share",
                      callback: (args) async {
                        if (args[0] == {}) {
                          return false;
                        }
                        try {
                          final Dio _dio = Dio();
                          final backgroundResponse = await _dio.get(
                              args[0]['backgroundLayerUrl'],
                              options:
                                  Options(responseType: ResponseType.bytes));
                          final stickerResponse = await _dio.get(
                              args[0]['stickerLayerUrl'],
                              options:
                                  Options(responseType: ResponseType.bytes));
                          final backgroundFile = await File(
                                  (await getTemporaryDirectory()).path +
                                      "/background.png")
                              .create(recursive: true);
                          final stickerFile = await File(
                                  (await getTemporaryDirectory()).path +
                                      "/sticker.png")
                              .create(recursive: true);
                          await backgroundFile
                              .writeAsBytes(backgroundResponse.data);
                          await stickerFile.writeAsBytes(stickerResponse.data);

                          await SocialShare.shareInstagramStory(
                              appId: dotenv.get("FACEBOOK_APPID"),
                              imagePath: stickerFile.path,
                              backgroundResourcePath: backgroundFile.path);
                          return true;
                        } catch (e) {
                          Fluttertoast.showToast(
                              msg: "인스타그램 스토리 공유에 실패했습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: toastTextColor,
                              backgroundColor: toastBackgroundColor);
                          return false;
                        }
                      });
                },
                onLoadStart: (controller, uri) async {
                  if (isFcmInit.value &&
                      isLogin.value &&
                      sessionToken.value != '' &&
                      uri?.origin == Uri.parse(address).origin &&
                      (await _cookieManager.getCookie(
                                  url: Uri.parse(
                                      RemoteConfigController().backUrl),
                                  name: "connect.sid"))
                              ?.value !=
                          sessionToken.value) {
                    try {
                      await _controller.value?.stopLoading();
                      await _cookieManager.deleteCookie(
                          url: Uri.parse(RemoteConfigController().backUrl),
                          name: "connect.sid");
                      await _cookieManager.setCookie(
                        url: Uri.parse(RemoteConfigController().backUrl),
                        name: "connect.sid",
                        value: sessionToken.value,
                      );
                      await _controller.value?.reload();
                    } catch (e) {
                      // TODO : handle error
                      Fluttertoast.showToast(
                          msg: "서버와의 연결에 실패했습니다.",
                          toastLength: Toast.LENGTH_SHORT,
                          textColor: toastTextColor,
                          backgroundColor: toastBackgroundColor);
                      isAuthLogin.value = false;
                    }
                  }
                },
                onLoadResourceCustomScheme: (controller, url) async {
                  if (!['intent'].contains(url.scheme)) {
                    await controller.stopLoading();
                    if (await canLaunchUrlString(url.toString())) {
                      await launchUrlString(url.toString(),
                          mode: LaunchMode.externalApplication);
                      return;
                    }
                    switch (url.scheme) {
                      case 'supertoss':
                        OpenStore.instance.open(
                            androidAppBundleId: "viva.republica.toss",
                            appStoreId: "839333328");
                        break;
                      case 'uber':
                        OpenStore.instance.open(
                            androidAppBundleId: "com.ubercab",
                            appStoreId: "368677368");
                        break;
                      case 'tmoneyonda':
                        OpenStore.instance.open(
                            androidAppBundleId: "kr.co.orangetaxi.passenger",
                            appStoreId: "1489918157");
                        break;
                      case 'kakaotalk': //카카오페이 결제시
                        OpenStore.instance.open(
                            androidAppBundleId: "com.kakao.talk",
                            appStoreId: "362057947");
                        break;
                      case 'kakaot':
                        OpenStore.instance.open(
                            androidAppBundleId: "com.kakao.taxi",
                            appStoreId: "981110422");
                        break;
                      default:
                        await Fluttertoast.showToast(
                            msg: "해당 앱을 실행할 수 없습니다.",
                            toastLength: Toast.LENGTH_SHORT,
                            textColor: Colors.black,
                            backgroundColor: Colors.white);
                        break;
                    }
                    return null;
                  }
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
                            textColor: toastTextColor,
                            backgroundColor: toastBackgroundColor);
                      }
                    }
                  }
                  return null;
                },
                onLoadError: (controller, url, code, message) {
                  // 될 때까지 리로드
                  if (!isLoaded.value && LoadCount.value < 10) {
                    LoadCount.value++;
                  } else if (isServerError.value == false &&
                      code != 102 &&
                      code != -999) {
                    Fluttertoast.showToast(
                        msg: "서버와의 연결에 실패했습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        textColor: toastTextColor,
                        backgroundColor: toastBackgroundColor);
                    isServerError.value = true;
                  }
                },
                onLoadStop: (finish, uri) async {
                  if (!isServerError.value) {
                    isLoaded.value = true;
                  }
                }),
          )),
      isTimerUp.value && isLoaded.value && isFcmInit.value
          ? const Stack()
          : Scaffold(
              body: FadeTransition(opacity: animation, child: loadingView())),
      isMustUpdate.value
          ? Container(
              color: notiColor,
              child: Center(
                  child: TaxiDialog(
                boxMainContent: {
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall,
                        children: const <TextSpan>[
                          TextSpan(
                            text: "새로운 버전",
                            style: TextStyle(
                                fontFamily: 'NanumSquare_acB',
                                fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: "이 "),
                          TextSpan(
                              text: "출시",
                              style: TextStyle(
                                  fontFamily: 'NanumSquare_acB',
                                  color: taxiPrimaryColor,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(text: "되었습니다!")
                        ]),
                  ),
                },
                boxSecondaryContent: {
                  Text("정상적인 사용을 위해 앱을 업데이트 해주세요.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                },
                rightButtonContent: "업데이트 하러가기",
                leftButtonContent: "앱 종료하기",
              )),
            )
          : const Stack(),
      isServerError.value
          ? Container(
              color: notiColor,
              child: Center(
                  child: TaxiDialog(
                boxMainContent: {
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall,
                        children: const <TextSpan>[
                          TextSpan(
                            text: "서버와의 ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "연결에 "),
                          TextSpan(
                              text: "실패",
                              style: TextStyle(
                                  color: taxiPrimaryColor,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(text: "했습니다.")
                        ]),
                  ),
                },
                boxSecondaryContent: {
                  Text("일시적인 오류일 수 있습니다.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                },
                rightButtonContent: "스토어로 가기",
                leftButtonContent: "앱 종료하기",
              )),
            )
          : const Stack()
    ]));
  }

  Future<bool> _goBack(
      BuildContext context,
      ValueNotifier<bool> backCount,
      ValueNotifier<bool> isAuthLogin,
      InAppWebViewController? _controller) async {
    Uri? current_uri = await _controller!.getUrl();
    final address = RemoteConfigController().frontUrl;
    if (Uri.parse(address).origin != current_uri?.origin) {
      await _controller.loadUrl(
          urlRequest: URLRequest(url: Uri.parse(address)));
      backCount.value = false;
      return false;
    } else if (await _controller.canGoBack() &&
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
        backgroundColor: toastBackgroundColor,
        textColor: toastTextColor,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    }
  }
}
