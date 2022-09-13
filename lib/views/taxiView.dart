import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/utils/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taxi_app/views/loadingView.dart';

class TaxiView extends HookWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  late InAppWebViewController _controller;
  final _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final _isLoaded = useState(false);
    final _sessionToken = useState("");
    final AnimationController _aniController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    )..forward();

    final Animation<double> _animation = CurvedAnimation(
      parent: _aniController,
      curve: Curves.easeIn,
    );

    useEffect(() {
      _storage.read(key: "sessionToken").then((value) {
        _sessionToken.value = value.toString();
      });
    }, []);
    String address = dotenv.get("FRONT_ADDRESS");

    return SafeArea(
        child: Stack(children: [
      InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(useHybridComposition: true)),
          initialUrlRequest: URLRequest(url: Uri.parse(address)),
          onWebViewCreated: (InAppWebViewController webcontroller) async {
            _controller = webcontroller;
            try {
              String? sessionToken = await _storage.read(key: "sessionToken");
              if (sessionToken == null) {
                return;
              }
              if (!await checkSession(sessionToken.toString())) {
                await _storage.deleteAll();
              } else {
                _sessionToken.value = sessionToken.toString();
                await _cookieManager.deleteAllCookies();
                await _cookieManager.setCookie(
                  url: Uri.parse(address),
                  name: "connect.sid",
                  value: sessionToken.toString(),
                );
              }
            } catch (e) {
              // TODO : REFACTORING ERROR HANGLING
            }
          },
          onLoadStop: (finish, uri) async {
            _isLoaded.value = true;
            try {
              Cookie? cookies = await _cookieManager.getCookie(
                  url: Uri.parse(address), name: "connect.sid");

              if (_sessionToken.value != cookies?.value) {
                if (await checkSession(cookies?.value)) {
                  _sessionToken.value = cookies?.value;
                  await _storage.write(
                      key: "sessionToken", value: cookies?.value);
                }
              }
            } catch (e) {
              // TODO : REFACTORING ERROR HANDLING
            }
          }),
      _isLoaded.value
          ? Stack()
          : FadeTransition(opacity: _animation, child: loadingView())
    ]));
  }
}
