import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/utils/fcmToken.dart';
import 'package:taxi_app/views/loadingView.dart';
import 'package:taxi_app/views/loginView.dart';
import 'package:taxi_app/utils/token.dart';

class TaxiView extends HookWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  late InAppWebViewController _controller;

  @override
  Widget build(BuildContext context) {
    final isLoaded = useState(false);
    final sessionToken = useState('');
    final isLogin = useState(false);
    final isAuthLogin = useState(true);

    final AnimationController aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> animation = CurvedAnimation(
      parent: aniController,
      curve: Curves.easeIn,
    );
    String address = dotenv.get("FRONT_ADDRESS");

    useEffect(() {
      if (isAuthLogin.value && !isLogin.value) {
        isLoaded.value = false;
        Token().getSession().then((value) async {
          if (value == null) {
            isLogin.value = false;
            isAuthLogin.value = false;
          } else {
            sessionToken.value = value;
            isLogin.value = true;
            isLoaded.value = true;
            await _controller.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(address)));
          }
        });
      }
      return;
    }, [isAuthLogin.value]);

    return SafeArea(
        child: Stack(children: [
      InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform:
                  InAppWebViewOptions(useShouldOverrideUrlLoading: true),
              android: AndroidInAppWebViewOptions(useHybridComposition: true)),
          initialUrlRequest: URLRequest(url: Uri.parse(address)),
          onWebViewCreated: (InAppWebViewController webcontroller) async {
            _controller = webcontroller;
          },
          // React Link는 Page를 로드하는 것이 아니라 history를 바꾸는 것이기 때문에 history 변화로 링크 변화를 감지해야함.
          onUpdateVisitedHistory: (controller, url, androidIsReload) async {
            // 세션이 만료되어 로그인 페이지로 돌아갈 시 자동으로 세션 갱신
            if (url.toString().contains("login") &&
                isLogin.value &&
                isAuthLogin.value) {
              String? session = await Token().getSession();
              if (session == null) {
                isLogin.value = false;
                isAuthLogin.value = false;
              } else {
                sessionToken.value = session;
                await _controller.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(address)));
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
              }
            }
          },
          onLoadStart: (controller, uri) async {
            if (sessionToken.value != '') {
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
            }
          },
          onLoadStop: (finish, uri) async {
            isLoaded.value = true;
          }),
      isLoaded.value
          ? Stack()
          : FadeTransition(opacity: animation, child: loadingView()),
      isAuthLogin.value ? Stack() : LoginView(isAuthLogin),
    ]));
  }
}
