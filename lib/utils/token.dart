import "package:dio/dio.dart";
import 'package:taxi_app/constants/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Token {
  String accessToken;
  String refreshToken;
  static late Token _instance;
  static final _storage = FlutterSecureStorage();

  Token._internal({required this.accessToken, required this.refreshToken});

  factory Token({String? accessToken, String? refreshToken}) {
    if (accessToken == null || refreshToken == null) {
      if (_instance == null) {
        _instance = Token._internal(accessToken: "", refreshToken: "");
      }
      return _instance;
    }
    _instance =
        Token._internal(accessToken: accessToken, refreshToken: refreshToken);
    return _instance;
  }

  Future<void> init() async {
    final accessToken = await getAccessTokenFromStorage();
    final refreshToken = await getRefreshTokenFromStorage();

    if (accessToken == null) {
      this.accessToken = '';
    } else {
      this.accessToken = accessToken;
    }

    if (refreshToken == null) {
      this.refreshToken = '';
    } else {
      this.refreshToken = refreshToken;
    }
  }

  static Token get instance => _instance;

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
    return this.accessToken;
  }

  String getRefreshToken() {
    return this.refreshToken;
  }

  Future<String?> getSession() {
    String address = dotenv.get("BACKEND_ADDRESS");

    final BaseOptions options = ConnectionOptions;
    Dio _dio = Dio(options);
    return _dio.get("/app/token/login", queryParameters: {
      "accessToken": accessToken,
    }).then((response) {
      if (response.statusCode == 403) {
        return null;
      }

      return response.headers['set-cookie'][0];
    }).catchError((error) {
      return null;
    });
  }

  Future<bool> updateAccessTokenUsingRefreshToken() {
    String address = dotenv.get("BACKEND_ADDRESS");

    final BaseOptions options = ConnectionOptions;
    Dio _dio = Dio(options);
    return _dio.get("/app/token/refresh", queryParameters: {
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
