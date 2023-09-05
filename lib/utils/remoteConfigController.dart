import "package:dio/dio.dart";
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info/package_info.dart';

class RemoteConfigController {
  String backUrl;
  String frontUrl;
  String ios_version;
  String android_version;

  static RemoteConfigController? _instance;

  final remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigController._internal(
      {required this.backUrl,
      required this.frontUrl,
      required this.ios_version,
      required this.android_version});

  factory RemoteConfigController(
      {String? backUrl,
      String? frontUrl,
      String? ios_version,
      String? android_version}) {
    if (frontUrl == null ||
        backUrl == null ||
        ios_version == null ||
        android_version == null) {
      return _instance ??= RemoteConfigController._internal(
          backUrl: 'https://taxi.sparcs.org/api/',
          frontUrl: 'https://taxi.sparcs.org',
          ios_version: '',
          android_version: '');
    }
    _instance = RemoteConfigController._internal(
        backUrl: backUrl,
        frontUrl: frontUrl,
        ios_version: ios_version,
        android_version: android_version);
    return _instance ??= RemoteConfigController._internal(
        backUrl: 'https://taxi.sparcs.org/api/',
        frontUrl: 'https://taxi.sparcs.org',
        ios_version: '',
        android_version: '');
  }

  Future<void> init() async {
    final value = await PackageInfo.fromPlatform();

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.setDefaults({
      "back_url": "https://taxi.sparcs.org/api/",
      "front_url": "https://taxi.sparcs.org",
      "version": value.version,
      "ios_version": value.version,
    });

    await remoteConfig.fetchAndActivate();

    this.backUrl =
        "https://api.taxi.dev.sparcs.org/"; // remoteConfig.getString("back_url");
    this.frontUrl =
        "https://taxi.dev.sparcs.org"; // remoteConfig.getString("front_url");
    this.android_version = remoteConfig.getString("version");
    this.ios_version = remoteConfig.getString("ios_version");

    return;
  }
}
