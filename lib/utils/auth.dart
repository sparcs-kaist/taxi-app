import "package:dio/dio.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<bool> checkSession(String sessionValue) {
  String address = dotenv.get("BACKEND_ADDRESS");

  final BaseOptions options = new BaseOptions(
    baseUrl: address + '/users',
    connectTimeout: 15000,
    receiveTimeout: 13000,
  );
  Dio _dio = Dio(options);
  return _dio
      .get("",
          options: Options(headers: {
            "Cookie": "connect.sid=" + sessionValue,
          }))
      .then((response) {
    print(response.statusCode);
    if (response.statusCode == 403) {
      return false;
    }
    return true;
  }).catchError((error) {
    print(error);
    return false;
  });
}
