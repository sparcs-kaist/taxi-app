import "package:dio/dio.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';

String address = RemoteConfigController().backUrl;

final BaseOptions connectionOptions = BaseOptions(
  baseUrl: address,
  connectTimeout: Duration(seconds: 150),
  receiveTimeout: Duration(seconds: 130),
);
