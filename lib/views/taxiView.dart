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
    final _sessionToken = useState("");
    final _isLogin = useState(false);
    final _isAuthLogin = useState(true);
    final _firstLoad = useState(false);

    final AnimationController _aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> _animation = CurvedAnimation(
      parent: _aniController,
      curve: Curves.easeIn,
    );
    String address = dotenv.get("FRONT_ADDRESS");

    useEffect(() {
      if (_firstLoad.value == false) {
        print(_isAuthLogin.value);
        Token().getSession().then((value) async {
          if (value == null) {
            _firstLoad.value = true;
            _isAuthLogin.value = false;
          } else {
            _sessionToken.value = value;
            _isLogin.value = true;
            _isLoaded.value = true;

            _firstLoad.value = true;
            await _controller.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(address)));
          }
        });
      }
      if (_firstLoad.value && _isAuthLogin.value && !_isLogin.value) {
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
          shouldOverrideUrlLoading:
              (controller, shouldOverrideUrlLoadingRequest) async {
            print(shouldOverrideUrlLoadingRequest.request.url);
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStart: (controller, uri) async {
            print("IT IS CALLED!");
            Cookie? cookies = await _cookieManager.getCookie(
                url: Uri.parse(address), name: "connect.sid");
            if (!await checkSession(cookies?.value) && _firstLoad.value) {
              _isLogin.value = false;
              _isAuthLogin.value = false;
            }
            print("RUNNED! WITH " + _sessionToken.value);
            await _cookieManager.deleteAllCookies();
            await _cookieManager.setCookie(
              url: Uri.parse(address),
              name: "connect.sid",
              value: _sessionToken.value,
            );
          },
          onLoadStop: (finish, uri) async {
            _isLoaded.value = true;
            try {
              Cookie? cookies = await _cookieManager.getCookie(
                  url: Uri.parse(address), name: "connect.sid");

              if (!await checkSession(cookies?.value)) {
                String? session = await Token().getSession();
                if (session == null) {
                  print("IT RUNNED!");
                  _isLogin.value = false;
                  _isAuthLogin.value = false;
                } else {
                  _sessionToken.value = session;
                  await _cookieManager.setCookie(
                    url: Uri.parse(address),
                    name: "connect.sid",
                    value: _sessionToken.value.toString(),
                  );
                }
              }
            } catch (e) {
              // TODO : REFACTORING ERROR HANDLING
            }
          }),
      _isLoaded.value
          ? Stack()
          : FadeTransition(opacity: _animation, child: loadingView()),
      _isAuthLogin.value ? Stack() : LoginView(_isAuthLogin),
    ]));
  }
}
