import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/utils/token.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginView extends HookWidget {
  final _backUrl = dotenv.get("BACKEND_ADDRESS");
  final _storage = FlutterSecureStorage();

  late final _isAuthLogin;

  LoginView(_isAuthLogin) {
    this._isAuthLogin = _isAuthLogin;
  }

  Future<Map<String, String>> getTokenFromLogin() async {
    final _url =
        Uri.parse(_backUrl).replace(path: "api/auth/app/token/generate");

    final callbackUrlScheme = "org.sparcs.taxi_app";

    final result = await FlutterWebAuth.authenticate(
        url: _url.toString(),
        callbackUrlScheme: callbackUrlScheme,
        preferEphemeral: true);

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
          Image(image: AssetImage('assets/img/taxiLogoText.png'), height: 60),
          Padding(padding: EdgeInsets.only(top: 15)),
          OutlinedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(Size(250, 45)),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF6E3678)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              child: Text("로그인",
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold))),
              onPressed: () async {
                // FCM 토큰 등록
                try {
                  final tokens = await getTokenFromLogin();
                  await Token()
                      .setAccessToken(accessToken: tokens['accessToken']!);
                  await Token()
                      .setRefreshToken(refreshToken: tokens['refreshToken']!);
                  await FcmToken().registerToken(tokens['accessToken']!);

                  _isAuthLogin.value = true;
                } catch (e) {
                  // TODO : handle error
                  Fluttertoast.showToast(
                    msg: "로그인에 실패했습니다.",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              }),
        ],
      )),
    );
  }
}
