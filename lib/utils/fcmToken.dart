import "package:dio/dio.dart";
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taxiapp/constants/constants.dart';

class FcmToken {
  String token;

  static FcmToken? _instance;

  final Dio _dio = Dio(connectionOptions);

  FcmToken._internal({required this.token});

  factory FcmToken({String? token}) {
    if (token == null) {
      return _instance ??= FcmToken._internal(token: '');
    }
    _instance = FcmToken._internal(token: token);
    return _instance ??= FcmToken._internal(token: '');
  }

  Future<void> init() async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) {
      this.token = '';
    } else {
      this.token = token;
    }
  }

  String get fcmToken => token;

  Future<bool> registerToken(String accessToken) {
    return _dio.post("auth/app/device", data: {
      "accessToken": accessToken,
      "deviceToken": token,
    }).then((response) async {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  Future<bool> removeToken(String accessToken) {
    return _dio.delete("auth/app/device", data: {
      "accessToken": accessToken,
      "deviceToken": token,
    }).then((response) async {
      return true;
    }).catchError((error) {
      return false;
    });
  }
}
