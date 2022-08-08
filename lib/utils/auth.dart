import "package:dio/dio.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxi_app/constants/constants.dart';

Future<bool> checkSession(String sessionValue) {
  String address = dotenv.get("BACKEND_ADDRESS");

  final BaseOptions options = ConnectionOptions;
  Dio _dio = Dio(options);
  return _dio
      .get("",
          options: Options(headers: {
            "Cookie": "connect.sid=" + sessionValue,
          }))
      .then((response) {
    if (response.statusCode == 403) {
      return false;
    }
    return true;
  }).catchError((error) {
    print(error);
    return false;
  });
}
