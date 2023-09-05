import "package:dio/dio.dart";
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';

String address = RemoteConfigController().backUrl;

final BaseOptions connectionOptions = BaseOptions(
  baseUrl: address,
  connectTimeout: Duration(seconds: 150),
  receiveTimeout: Duration(seconds: 130),
);

const defaultDialogUpperTitlePadding = Padding(padding: EdgeInsets.all(15));

const defaultDialogMedianTitlePadding = Padding(padding: EdgeInsets.all(2));

const defaultDialogLowerTitlePadding = Padding(padding: EdgeInsets.all(10));

const defaultDialogButtonSize = Size(150, 35);

final defaultDialogButtonBorderRadius = BorderRadius.circular(5.0);
