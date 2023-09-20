void initialFirebase() {
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.data['url'] != null) {
      if (message.data['url'] ==
          (await _controller.value!.getUrl())
              ?.path
              .replaceAll("chatting", "myroom")) {
        return;
      } else {
        handleMessage(message);
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['url'] != null) {
      Uri newUri = Uri.parse(RemoteConfigController().frontUrl)
          .replace(path: message.data['url']);
      url.value = newUri.toString();
      LoadCount.value += 1;
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      if (message.data['url'] != null) {
        Uri newUri = Uri.parse(RemoteConfigController().frontUrl)
            .replace(path: message.data['url']);
        url.value = newUri.toString();
        LoadCount.value += 1;
      }
    }
  });

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      if (details.payload != null) {
        url.value = RemoteConfigController().frontUrl + details.payload!;
        LoadCount.value += 1;
      }
    },
  );

  flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails()
      .then((NotificationAppLaunchDetails? details) {
    if (details != null) {
      if (details.didNotificationLaunchApp &&
          details.notificationResponse?.payload != null) {
        Uri new_uri = Uri.parse(address)
            .replace(path: details.notificationResponse!.payload!);
        url.value = new_uri.toString();
        LoadCount.value += 1;
      }
    }
  });

  FirebaseDynamicLinks.instance.onLink.listen((event) {
    url.value = event.link.toString();
    LoadCount.value += 1;
  });

  FirebaseDynamicLinks.instance.getInitialLink().then((initalLink) async {
    if (initalLink != null) {
      url.value = initalLink.link.toString();
      LoadCount.value += 1;
    } else {
      final _appLinks = AppLinks();
      final Uri? uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        final PendingDynamicLinkData? appLinkData =
            await FirebaseDynamicLinks.instance.getDynamicLink(uri);
        if (appLinkData != null) {
          url.value = appLinkData.link.toString();
          LoadCount.value += 1;
        }
      }
    }
  });
}
