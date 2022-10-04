import "package:dio/dio.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

String address = dotenv.get("BACKEND_ADDRESS");

final BaseOptions ConnectionOptions = BaseOptions(

  baseUrl: address + '/users',
  connectTimeout: 15000,
  receiveTimeout: 13000,
);
