import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_store/open_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/constants/constants.dart';

class TaxiDialog extends StatelessWidget {
  late Set<Widget> boxContent;
  late String leftButtonContent;
  late String rightButtonContent;
  TaxiDialog(
      {super.key,
      required this.boxContent,
      required this.leftButtonContent,
      required this.rightButtonContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 172,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            defaultDialogPadding,
            ...boxContent,
            defaultDialogPadding,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      fixedSize: defaultDialogButtonSize,
                      backgroundColor: const Color(0xFFFAF8FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: defaultDialogButtonBorderRadius,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Text(leftButtonContent,
                        style: Theme.of(context).textTheme.labelMedium),
                    onPressed: () async {
                      if (Platform.isIOS) {
                        exit(0);
                      } else {
                        SystemNavigator.pop();
                      }
                    }),
                const Padding(
                  padding: EdgeInsets.all(10),
                ),
                OutlinedButton(
                    style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(defaultDialogButtonSize),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: defaultDialogButtonBorderRadius,
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text(rightButtonContent,
                        style: Theme.of(context).textTheme.labelLarge),
                    onPressed: () async {
                      OpenStore.instance.open(
                          androidAppBundleId: dotenv.get("ANDROID_APPID"),
                          appStoreId: dotenv.get("IOS_APPID"));
                    }),
              ],
            ),
            //하단 패딩
            const Padding(padding: EdgeInsets.only(bottom: 15)),
          ]),
    );
  }
}
