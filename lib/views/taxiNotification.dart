import "package:flutter/material.dart";

import 'package:taxi_flutter_app/constants/theme.dart';

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
        leadingPadding: const EdgeInsets.only(right: 20),
        forceActionsBelow: true,
        padding: EdgeInsets.only(
            left: 20, right: 20, top: MediaQuery.of(context).padding.top + 20),
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
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextSpan(
                      text: " / " + subTitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              content,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        leading:
            Image(image: NetworkImage("https://via.placeholder.com/40x40")),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Positioned(
            bottom: 20,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  fixedSize: defaultNotificationButtonSize,
                  padding: defaultNotificationButtonInnerPadding,
                  backgroundColor: taxiPrimaryMaterialColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: defaultNotificationButtonBorderRadius,
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(button.keys.first,
                    style: Theme.of(context).textTheme.labelSmall),
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
