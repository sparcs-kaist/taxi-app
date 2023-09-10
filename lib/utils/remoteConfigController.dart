import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info/package_info.dart';

class RemoteConfigController {
  String backUrl;
  String frontUrl;
  String iosVersion;
  String androidVersion;

  static RemoteConfigController? _instance;

  final remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigController._internal(
      {required this.backUrl,
      required this.frontUrl,
      required this.iosVersion,
      required this.androidVersion});

  factory RemoteConfigController(
      {String? backUrl,
      String? frontUrl,
      String? iosVersion,
      String? androidVersion}) {
    if (frontUrl == null ||
        backUrl == null ||
        iosVersion == null ||
        androidVersion == null) {
      return _instance ??= RemoteConfigController._internal(
          backUrl: '', frontUrl: '', iosVersion: '', androidVersion: '');
    }
    _instance = RemoteConfigController._internal(
        backUrl: backUrl,
        frontUrl: frontUrl,
        iosVersion: iosVersion,
        androidVersion: androidVersion);
    return _instance ??= RemoteConfigController._internal(
        backUrl: '', frontUrl: '', iosVersion: '', androidVersion: '');
  }

  Future<void> init() async {
    final value = await PackageInfo.fromPlatform();

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.setDefaults({
      "back_url": "https://taxi.sparcs.org/api/",
      "front_url": "https://taxi.sparcs.org/",
      "version": value.version,
      "ios_version": value.version,
    });

    await remoteConfig.fetchAndActivate();

    this.backUrl = remoteConfig.getString("back_url");
    this.frontUrl = remoteConfig.getString("front_url");
    this.androidVersion = remoteConfig.getString("version");
    this.iosVersion = remoteConfig.getString("ios_version");

    return;
  }
}
