import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/views/loadingView.dart';
import 'package:taxiapp/views/loginView.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaxiView extends HookWidget {
  Uri? init_uri;
  final CookieManager _cookieManager = CookieManager.instance();
  late InAppWebViewController _controller;

  TaxiView({this.init_uri});

  @override
  Widget build(BuildContext context) {
    print("PRINTED ONLINE");
    print("init uri is ${init_uri}");

    final isLoaded = useState(false);
    final sessionToken = useState('');
    final isLogin = useState(false);
    final isAuthLogin = useState(true);
    final backCount = useState(false);
    final isFirstLoaded = useState(false);
    final isWebControllerInit = useState(false);

    final AnimationController aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> animation = CurvedAnimation(
      parent: aniController,
      curve: Curves.easeIn,
    );
    String address = dotenv.get("FRONT_ADDRESS");

    useEffect(() {
      print("USE EFFECT");
      if (isWebControllerInit.value) {
        _controller.loadUrl(urlRequest: URLRequest(url: init_uri));
      }
    }, [init_uri, isWebControllerInit.value]);

    useEffect(() {
      if (isLogin.value && init_uri != null) {
        isFirstLoaded.value = true;
        _controller.loadUrl(urlRequest: URLRequest(url: init_uri));
      }
      if (isAuthLogin.value && !isLogin.value) {
        Token().getSession().then((value) async {
          if (value == null) {
            isLogin.value = false;
            isAuthLogin.value = false;
          } else {
            sessionToken.value = value;
            isLogin.value = true;
            try {
              print(isWebControllerInit.value);
              if (isFirstLoaded.value == false &&
                  init_uri != null &&
                  isWebControllerInit.value == true) {
                isFirstLoaded.value = true;
                await _controller.loadUrl(
                    urlRequest: URLRequest(url: init_uri));
              } else {
                await _controller.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(address)));
              }
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
          onWillPop: () => _goBack(context, backCount, isAuthLogin),
          child: InAppWebView(
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform:
                      InAppWebViewOptions(useShouldOverrideUrlLoading: true),
                  android:
                      AndroidInAppWebViewOptions(useHybridComposition: true)),
              initialUrlRequest: URLRequest(url: Uri.parse(address)),
              onWebViewCreated: (InAppWebViewController webcontroller) {
                _controller = webcontroller;
                isWebControllerInit.value = true;
              },
              // React Link는 Page를 로드하는 것이 아니라 history를 바꾸는 것이기 때문에 history 변화로 링크 변화를 감지해야함.
              onUpdateVisitedHistory: (controller, url, androidIsReload) async {
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
                      await _controller.loadUrl(
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
              onLoadStop: (finish, uri) async {})),
      isAuthLogin.value ? Stack() : LoginView(isAuthLogin),
      isLoaded.value
          ? Stack()
          : Scaffold(
              body: FadeTransition(opacity: animation, child: loadingView())),
    ]));
  }

  Future<bool> _goBack(BuildContext context, ValueNotifier<bool> backCount,
      ValueNotifier<bool> isAuthLogin) async {
    Uri? current_uri = await _controller.getUrl();
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
