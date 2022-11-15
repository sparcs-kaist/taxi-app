import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/utils/token.dart';

class LoginView extends HookWidget {
  final _backUrl = dotenv.get("BACKEND_ADDRESS");
  final _storage = FlutterSecureStorage();

  late final _isAuthLogin;

  LoginView(_isAuthLogin) {
    this._isAuthLogin = _isAuthLogin;
  }

  Future<Map<String, String>> getTokenFromLogin() async {
    final url = Uri.http("localhost:3526", "/auth/login/app");
    final callbackUrlScheme = "org.sparcs.taxiApp";

    final result = await FlutterWebAuth.authenticate(
      url: url.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );

    final String accessToken =
        Uri.parse(result).queryParameters['accessToken'] ?? '';
    final String refreshToken =
        Uri.parse(result).queryParameters['refreshToken'] ?? '';

    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage('assets/img/taxiLogo.png'), height: 100),
          Padding(padding: EdgeInsets.only(top: 15)),
          OutlinedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(Size(200, 50)),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              child: Text("로그인", style: TextStyle(fontSize: 20)),
              onPressed: () async {
                final tokens = await getTokenFromLogin();
                await Token()
                    .setAccessToken(accessToken: tokens['accessToken']!);
                await Token()
                    .setRefreshToken(refreshToken: tokens['refreshToken']!);
                _isAuthLogin.value = true;
              }),
        ],
      )),
    );
  }
}
