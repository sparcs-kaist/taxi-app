import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/utils/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taxi_app/views/loadingView.dart';
import 'package:taxi_app/views/loginView.dart';
import 'package:taxi_app/utils/token.dart';

class TaxiView extends HookWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  late InAppWebViewController _controller;

  final _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final _isLoaded = useState(false);
    final _sessionToken = useState('');
    final _isLogin = useState(false);
    final _isAuthLogin = useState(true);

    final AnimationController _aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> _animation = CurvedAnimation(
      parent: _aniController,
      curve: Curves.easeIn,
    );
    String address = dotenv.get("FRONT_ADDRESS");

    useEffect(() {
      if (_isAuthLogin.value && !_isLogin.value) {
        _isLoaded.value = false;
        Token().getSession().then((value) async {
          if (value == null) {
            _isLogin.value = false;
            _isAuthLogin.value = false;
          } else {
            _sessionToken.value = value;
            _isLogin.value = true;
            _isLoaded.value = true;
            await _controller.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(address)));
          }
        });
      }
      return;
    }, [_isAuthLogin.value]);

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
            print(url);
            // 세션이 만료되어 로그인 페이지로 돌아갈 시 자동으로 세션 갱신
            if (url.toString().contains("login") &&
                _isLogin.value &&
                _isAuthLogin.value) {
              String? session = await Token().getSession();
              if (session == null) {
                _isLogin.value = false;
                _isAuthLogin.value = false;
              } else {
                _sessionToken.value = session;
                await _controller.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(address)));
              }
            }
            // 로그아웃 감지 시 토큰 지우고 처음 로그인 페이지로 돌아가기
            if (url.toString().contains("logout") && _isLogin.value) {
              await Token().deleteAll();
              _isLogin.value = false;
              _isAuthLogin.value = false;
            }
          },
          onLoadStart: (controller, uri) async {
            if (_sessionToken.value != '') {
              await _cookieManager.deleteAllCookies();
              await _cookieManager.setCookie(
                url: Uri.parse(address),
                name: "connect.sid",
                value: _sessionToken.value,
              );
            }
          },
          onLoadStop: (finish, uri) async {
            _isLoaded.value = true;
          }),
      _isLoaded.value
          ? Stack()
          : FadeTransition(opacity: _animation, child: loadingView()),
      _isAuthLogin.value ? Stack() : LoginView(_isAuthLogin),
    ]));
  }
}
