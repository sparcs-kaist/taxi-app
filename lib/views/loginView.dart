import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginView extends HookWidget {
  final _backUrl = dotenv.get("BACKEND_ADDRESS");

  Future<String?> getTokenFromLogin() async {
    final url = Uri.https(_backUrl, "/auth/generateToken");
    final callbackUrlScheme = "org.sparcs.taxiApp";

    final result = await FlutterWebAuth.authenticate(
      url: url.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );

    final String? accessToken =
        Uri.parse(result).queryParameters['accessToken'];
    final String? refreshToken =
        Uri.parse(result).queryParameters['refreshToken'];

    print(accessToken);

    return accessToken;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            child: Text('LoginView'),
            onPressed: () async {
              final token = await getTokenFromLogin();
              print(token);
            }),
      ),
    );
  }
}
