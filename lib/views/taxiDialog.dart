import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_store/open_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/constants/theme.dart';

class TaxiDialog extends StatelessWidget {
  late Set<Widget> boxMainContent;
  late Set<Widget> boxSecondaryContent;
  late String leftButtonContent;
  late String rightButtonContent;
  TaxiDialog(
      {super.key,
      required this.boxMainContent,
      required this.boxSecondaryContent,
      required this.leftButtonContent,
      required this.rightButtonContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: dialogBarrierColor,
      child: Dialog(
        alignment: Alignment.center,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: Theme.of(context).dialogTheme.shape,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              defaultDialogUpperTitlePadding,
              ...boxMainContent,
              defaultDialogMedianTitlePadding,
              ...boxSecondaryContent,
              defaultDialogLowerTitlePadding,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  defaultDialogPadding,
                  ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Text(leftButtonContent,
                          style: Theme.of(context).textTheme.labelMedium),
                      onPressed: () async {
                        if (Platform.isIOS) {
                          exit(0);
                        } else {
                          SystemNavigator.pop();
                        }
                      }),
                  defaultDialogVerticalMedianButtonPadding,
                  OutlinedButton(
                      style: Theme.of(context).outlinedButtonTheme.style,
                      child: Text(rightButtonContent,
                          style: Theme.of(context).textTheme.labelLarge),
                      onPressed: () async {
                        OpenStore.instance.open(
                            androidAppBundleId: dotenv.get("ANDROID_APPID"),
                            appStoreId: dotenv.get("IOS_APPID"));
                      }),
                  defaultDialogPadding,
                ],
              ),
              defaultDialogLowerButtonPadding
            ]),
      ),
    );
  }
}
