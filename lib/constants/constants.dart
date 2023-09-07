import "package:dio/dio.dart";
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';

String address = RemoteConfigController().backUrl;

final BaseOptions connectionOptions = BaseOptions(
  baseUrl: address,
  connectTimeout: const Duration(seconds: 150),
  receiveTimeout: const Duration(seconds: 130),
);

//아래의 상수들은 피그마 기준 상의 패딩 픽셀과는 차이를 두고 있지만,
//이는 모바일 환경상 웹뷰와 같은 간격을 제시하기 위해 설정한 값들입니다.
const defaultDialogUpperTitlePadding = Padding(padding: EdgeInsets.all(15));

const defaultDialogMedianTitlePadding = Padding(padding: EdgeInsets.all(2));

const defaultDialogLowerTitlePadding = Padding(padding: EdgeInsets.all(10));

const defaultDialogVerticalMedianButtonPadding =
    Padding(padding: EdgeInsets.all(5));

const defaultDialogLowerButtonPadding = Padding(padding: EdgeInsets.all(3));

const defaultDialogButtonSize = Size(150, 35);

final defaultDialogButtonBorderRadius = BorderRadius.circular(10.0);
