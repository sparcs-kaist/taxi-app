import 'dart:io';
import "package:dio/dio.dart";
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';

class FcmToken {
  String token;

  static FcmToken? _instance;

  final Dio _dio = Dio();

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
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers["Origin"] = options.uri.origin;
      return handler.next(options);
    }, onResponse: (response, handler) async {
      return handler.next(response);
    }, onError: (error, handler) async {
      return handler.next(error);
    }));

    if (token == null) {
      this.token = '';
    } else {
      this.token = token;
    }
  }

  String get fcmToken => token;

  Future<bool> registerToken(String accessToken) async {
    _dio.options.baseUrl = RemoteConfigController().backUrl;
    return _dio.post("auth/app/device", data: {
      "accessToken": accessToken,
      "deviceToken": token,
    }).then((response) async {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  Future<bool> removeToken(String accessToken) async {
    _dio.options.baseUrl = RemoteConfigController().backUrl;
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
