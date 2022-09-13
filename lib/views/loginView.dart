import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginView extends HookWidget {
  final _backUrl = dotenv.get("BACKEND_ADDRESS");

  Future<String?> getTokenFromLogin() async {
    final url = Uri.https(_backUrl, "/auth/login");
    final callbackUrlScheme = "org.sparcs.taxi_app";

    final result = await FlutterWebAuth.authenticate(
      url: url.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );

    final String? token = Uri.parse(result).queryParameters['token'];

    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('LoginView'),
      ),
    );
  }
}
