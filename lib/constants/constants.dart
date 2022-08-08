import "package:dio/dio.dart";

final BaseOptions ConnectionOptions = new BaseOptions(
    baseUrl: address + '/users',
    connectTimeout: 15000,
    receiveTimeout: 13000,
  );