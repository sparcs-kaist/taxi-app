import "package:flutter/material.dart";

import 'package:taxiapp/constants/theme.dart';

class TaxiNotification extends StatelessWidget {
  TaxiNotification(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.content,
      required this.button,
      required this.imageUrl});
  late final String title;
  late final String subTitle;
  late final String content;
  late final Map<String, Uri> button;
  late final Uri imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MaterialBanner(
        leadingPadding: EdgeInsets.symmetric(
            horizontal: taxiNotificationPadding,
            vertical: taxiNotificationPadding / 2),
        forceActionsBelow: true,
        padding: EdgeInsets.only(
            left: taxiNotificationPadding / devicePixelRatio,
            right: taxiNotificationPadding / devicePixelRatio,
            bottom: taxiNotificationPadding / devicePixelRatio,
            top: MediaQuery.of(context).padding.top + 20),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          verticalDirection: VerticalDirection.down,
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                        ),
                  ),
                  TextSpan(
                      text: " / " + subTitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4),
            ),
          ],
        ),
        leading: const Icon(Icons.notifications, size: 40), //40x40
        backgroundColor: Colors.white,
        actions: <Widget>[
          Positioned(
            bottom: 20,
            right: 20,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  fixedSize: defaultNotificationButtonSize,
                  padding: defaultNotificationButtonInnerPadding,
                  backgroundColor: taxiPrimaryMaterialColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: defaultNotificationButtonBorderRadius,
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  button.keys.first,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontSize: 14),
                ),
                onPressed: () {}),
          ),
        ],
      ),
      Positioned(
          top: MediaQuery.of(context).padding.top,
          child: Container(
            width: 430,
            height: 5,
            color: taxiPrimaryColor,
          ))
    ]);
  }
}
