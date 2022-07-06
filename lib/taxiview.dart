import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/utils/auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TaxiView extends HookWidget {
  final CookieManager _cookieManager = CookieManager.instance();
  late InAppWebViewController _controller;
  final _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final _isLoaded = useState(false);
    final _sessionToken = useState("");

    useEffect(() {
      _storage.read(key: "sessionToken").then((value) {
        _sessionToken.value = value.toString();
      });
    }, []);
    String address = dotenv.get("FRONT_ADDRESS");

    return SafeArea(
        child: Stack(children: [
      InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(address)),
          onWebViewCreated: (InAppWebViewController webcontroller) async {
            _controller = webcontroller;
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
          },
          onLoadStop: (finish, uri) async {
            _isLoaded.value = true;
            Cookie? cookies = await _cookieManager.getCookie(
                url: Uri.parse(address), name: "connect.sid");

            if (_sessionToken.value != cookies?.value) {
              print("저장된 코드와 미일치");
              if (await checkSession(cookies?.value)) {
                _sessionToken.value = cookies?.value;
                await _storage.write(
                    key: "sessionToken", value: cookies?.value);
                print("SESSION TOKEN UPDATED!");
              }
            }

            print("Cookies : " + cookies?.value);
            print("CurrentURL : " + uri.toString());
          }),
      _isLoaded.value ? Stack() : Center(child: CircularProgressIndicator())
    ]));
  }
}
