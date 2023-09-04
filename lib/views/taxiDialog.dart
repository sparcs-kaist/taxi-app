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
      width: 340,
      height: 155,
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
                const Padding(
                  padding: EdgeInsets.all(
                      7), //피그마 기준 상으로 버튼 간의 간격은 10px이나 모바일 환경상 웹뷰와 같은 간격을 제시하기 위해 7로 설정
                ),
                OutlinedButton(
                    style: Theme.of(context).outlinedButtonTheme.style,
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
            const Padding(padding: EdgeInsets.only(bottom: 10)),
          ]),
    );
  }
}
