import "package:dio/dio.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

String address = dotenv.get("BACKEND_ADDRESS");

final BaseOptions connectionOptions = BaseOptions(
  baseUrl: address,
  connectTimeout: Duration(seconds: 150),
  receiveTimeout: Duration(seconds: 130),
);
