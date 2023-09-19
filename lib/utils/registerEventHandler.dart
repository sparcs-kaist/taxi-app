import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_share/social_share.dart';
import 'package:taxiapp/utils/fcmToken.dart';
import 'package:taxiapp/utils/remoteConfigController.dart';
import 'package:taxiapp/utils/token.dart';

void registerEventHandler(
    InAppWebViewController controller,
    ValueNotifier<bool> isLogin,
    ValueNotifier<bool> isAuthLogin,
    Function createOverlayNotification,
    CookieManager cookieManager,
    Color toastTextColor,
    Color toastBackgroundColor) {
  controller.addJavaScriptHandler(
    handlerName: "auth_update",
    callback: (arguments) async {
      // 로그인 해제 시 로그인 State 변경
      if (arguments == [{}]) {
        isLogin.value = false;
        return;
      }
      // 로그인 성공 시 / 기존 토큰 삭제 후 새로운 토큰 저장
      if (!isAuthLogin.value) {
        if (arguments[0]['accessToken'] != null &&
            arguments[0]['refreshToken'] != null) {
          await Token().deleteAll();
          await Token()
              .setAccessToken(accessToken: arguments[0]['accessToken']);
          await Token()
              .setRefreshToken(refreshToken: arguments[0]['refreshToken']);
          await FcmToken().registerToken(arguments[0]['accessToken']);
          isAuthLogin.value = true;
        }
      }
      return;
    },
  );

  controller.addJavaScriptHandler(
      handlerName: "auth_logout",
      callback: (args) async {
        try {
          await FcmToken().removeToken(Token().getAccessToken());
          await Token().deleteAll();
          await cookieManager.deleteAllCookies();
          isLogin.value = false;
          isAuthLogin.value = false;
          await controller.loadUrl(
              urlRequest: URLRequest(
                  url:
                      Uri.parse(RemoteConfigController().frontUrl.toString())));
        } catch (e) {
          // TODO
          Fluttertoast.showToast(
              msg: "서버와의 연결에 실패했습니다.",
              toastLength: Toast.LENGTH_SHORT,
              textColor: toastTextColor,
              backgroundColor: toastBackgroundColor);
          isAuthLogin.value = false;
        }
      });

  controller.addJavaScriptHandler(
      handlerName: "try_notification",
      callback: (args) async {
        if (await Permission.notification.isGranted) {
          return true;
        } else {
          openAppSettings();
          Fluttertoast.showToast(
              msg: "알림 권한을 허용해주세요.",
              toastLength: Toast.LENGTH_SHORT,
              textColor: toastTextColor,
              backgroundColor: toastBackgroundColor);
          return false;
        }
      });

  controller.addJavaScriptHandler(
      handlerName: "clipboard_copy",
      callback: (args) async {
        if (Platform.isAndroid) {
          await Clipboard.setData(ClipboardData(text: args[0]));
        }
      });

  // Web -> App
  controller.addJavaScriptHandler(
      handlerName: "popup_inAppNotification",
      callback: (args) async {
        createOverlayNotification(
            title: args[0]['title'].toString(),
            subTitle: args[0]['subtitle'].toString(),
            content: args[0]['content'].toString(),
            button: {
              args[0]['button']['text'].toString():
                  (args[0]['button']['path'].toString() != "")
                      ? Uri.parse(args[0]['button']['path'].toString())
                      : Uri.parse("")
            },
            imageUrl: (args[0]['type'].toString() ==
                    "default") //TODO: type showMaterialBanner 함수에서 관리
                ? Uri.parse(args[0]['imageUrl'].toString())
                : Uri.parse(""));
      });

  controller.addJavaScriptHandler(
      handlerName: "popup_instagram_story_share",
      callback: (args) async {
        if (args[0] == {}) {
          return false;
        }
        try {
          final Dio _dio = Dio();
          final backgroundResponse = await _dio.get(
              args[0]['backgroundLayerUrl'],
              options: Options(responseType: ResponseType.bytes));
          final stickerResponse = await _dio.get(args[0]['stickerLayerUrl'],
              options: Options(responseType: ResponseType.bytes));
          final backgroundFile = await File(
                  (await getTemporaryDirectory()).path + "/background.png")
              .create(recursive: true);
          final stickerFile =
              await File((await getTemporaryDirectory()).path + "/sticker.png")
                  .create(recursive: true);
          await backgroundFile.writeAsBytes(backgroundResponse.data);
          await stickerFile.writeAsBytes(stickerResponse.data);

          await SocialShare.shareInstagramStory(
              appId: dotenv.get("FACEBOOK_APPID"),
              imagePath: stickerFile.path,
              backgroundResourcePath: backgroundFile.path);
          return true;
        } catch (e) {
          Fluttertoast.showToast(
              msg: "인스타그램 스토리 공유에 실패했습니다.",
              toastLength: Toast.LENGTH_SHORT,
              textColor: toastTextColor,
              backgroundColor: toastBackgroundColor);
          return false;
        }
      });
}
