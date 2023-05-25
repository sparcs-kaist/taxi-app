import 'dart:io';

import "package:dio/dio.dart";
import 'package:taxiapp/constants/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:taxiapp/utils/fcmToken.dart';

class Token {
  String accessToken;
  String refreshToken;
  static Token? _instance;
  static final _storage = FlutterSecureStorage();

  final Dio _dio = Dio(connectionOptions);
  final CookieJar _cookieJar = CookieJar();

  Token._internal({required this.accessToken, required this.refreshToken});

  factory Token({String? accessToken, String? refreshToken}) {
    if (accessToken == null || refreshToken == null) {
      return _instance ??= Token._internal(accessToken: '', refreshToken: '');
    }
    _instance =
        Token._internal(accessToken: accessToken, refreshToken: refreshToken);
    return _instance ??= Token._internal(accessToken: '', refreshToken: '');
  }

  Future<void> init() async {
    accessToken = (await getAccessTokenFromStorage()) ?? '';
    refreshToken = (await getRefreshTokenFromStorage()) ?? '';
  }

  Future<void> setAccessToken({required String accessToken}) async {
    this.accessToken = accessToken;
    await setAccessTokenAtStorage(accessToken);
  }

  Future<void> setRefreshToken({required String refreshToken}) async {
    this.refreshToken = refreshToken;
    await setRefreshTokenAtStorage(refreshToken);
  }

  Future<void> deleteAll() async {
    await setAccessToken(accessToken: '');
    await setRefreshToken(refreshToken: '');
  }

  String getAccessToken() {
    return accessToken;
  }

  String getRefreshToken() {
    return refreshToken;
  }

  Future<String?> getSession() async {
    _dio.interceptors.add(CookieManager(_cookieJar));
    if (FcmToken().token == '') {
      await FcmToken().init();
    }
    return _dio.get("/auth/app/token/login", queryParameters: {
      "accessToken": accessToken,
      "deviceToken": FcmToken().fcmToken
    }, options: Options(validateStatus: ((status) {
      return (status ?? 200) < 500;
    }))).then((response) async {
      if (response.statusCode == 403) {
        return null;
      }
      if (response.statusCode == 401 &&
          response.data['message'] == "Expired token") {
        if (await updateAccessTokenUsingRefreshToken()) {
          return await getSession();
        }
        return null;
      }
      if (response.statusCode == 200) {
        List<Cookie> cookies = await _cookieJar.loadForRequest(
            Uri.parse(connectionOptions.baseUrl + "auth/app/token/login"));
        for (Cookie cookie in cookies) {
          if (cookie.name == "connect.sid") {
            return cookie.value;
          }
        }
      }

      return null;
    }).catchError((error) {
      return null;
    });
  }

  Future<bool> updateAccessTokenUsingRefreshToken() {
    return _dio.get("/auth/app/token/refresh", queryParameters: {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    }).then((response) async {
      if (response.statusCode == 403) {
        return false;
      }
      await setAccessToken(accessToken: response.data['accessToken']);
      await setRefreshToken(refreshToken: response.data['refreshToken']);
      return true;
    }).catchError((error) {
      return false;
    });
  }

  static Future<String?> getAccessTokenFromStorage() {
    return _storage.read(key: "accessToken").then((value) {
      if (value != null) {
        return value;
      }
      return value;
    });
  }

  static Future<String?> getRefreshTokenFromStorage() {
    return _storage.read(key: "refreshToken").then((value) {
      if (value != null) {
        return value;
      }
      return value;
    });
  }

  static Future<bool> setAccessTokenAtStorage(String accessToken) {
    return _storage.write(key: 'accessToken', value: accessToken).then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  static Future<bool> setRefreshTokenAtStorage(String refreshToken) {
    return _storage
        .write(key: 'refreshToken', value: refreshToken)
        .then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
