import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_store/open_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taxiapp/constants/theme.dart';

class TaxiDialog extends StatelessWidget {
  late Set<Widget> boxMainContent;

  late String leftButtonContent;
  late String rightButtonContent;
  late Function? leftButtonFunction;
  late Function? rightButtonFunction;
  TaxiDialog(
      {super.key,
      required this.boxMainContent,
      required this.leftButtonContent,
      this.leftButtonFunction,
      required this.rightButtonContent,
      this.rightButtonFunction});

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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                left: 20,
                top: 16,
                child: TaxiDialogTitle(
                    title: "제목", icon: const Icon(Icons.person))),
            // Positioned(
            //     left: 20,
            //     top: 16,
            //     child: TaxiDialogProfile(
            //         profileImage: "", profileName: "profileName")),
            // Positioned(right: 10, top: 10, child: TaxiDialogCloseButton(() {})),
            Positioned(
              bottom: 10,
              left: 10,
              child: TaxiDialogButton(
                  leftButtonContent: leftButtonContent,
                  leftButtonFunction: (leftButtonFunction == null)
                      ? () {}
                      : leftButtonFunction!,
                  rightButtonContent: rightButtonContent,
                  rightButtonFunction: (rightButtonFunction == null)
                      ? () {}
                      : rightButtonFunction!),
            ),
          ],
        ),
      ),
    );
  }
}

class TaxiDialogMidText extends StatelessWidget {
  late String midTitle;
  late String midContext;
  TaxiDialogMidText({required this.midTitle, required this.midContext});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(midTitle,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(fontSize: 12, color: notiColor)),
        const SizedBox(height: 5.0),
        Text(
          midContext,
          style: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(fontSize: 14, color: toastTextColor),
        )
      ],
    );
  }
}

class TaxiDialogDescription extends StatelessWidget {
  late String description;
  TaxiDialogDescription(this.description);
  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12),
    );
  }
}

class TaxiDialogCloseButton extends StatelessWidget {
  late Function onPressed;
  TaxiDialogCloseButton(this.onPressed);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close, size: 24),
      onPressed: () {
        onPressed();
      },
    );
  }
}

class TaxiDialogProfile extends StatelessWidget {
  late String profileImage;
  late String profileName;
  TaxiDialogProfile({required this.profileImage, required this.profileName});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: Image.network(profileImage).image,
        ),
        const SizedBox(width: 12),
        Text(profileName,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontSize: 16)),
      ],
    );
  }
}

class TaxiDialogTitle extends StatelessWidget {
  late String title;
  late Icon icon;
  TaxiDialogTitle({required this.title, this.icon = const Icon(null)});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        (icon != const Icon(null))
            ? Row(
                children: [
                  icon,
                  const SizedBox(width: 4.0),
                ],
              )
            : Container(),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}

class TaxiDialogAccentContent extends StatelessWidget {
  TaxiDialogAccentContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "asd",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6.0),
        Text("asd", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class TaxiDialogButton extends StatelessWidget {
  late String leftButtonContent;
  late String rightButtonContent;
  late Function leftButtonFunction;
  late Function rightButtonFunction;
  TaxiDialogButton(
      {required this.leftButtonContent,
      required this.leftButtonFunction,
      required this.rightButtonContent,
      required this.rightButtonFunction});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            defaultDialogPadding,
            Expanded(
              child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: Text(
                    leftButtonContent,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.visible,
                  ),
                  onPressed: () async {
                    leftButtonFunction();
                  }),
            ),
            defaultDialogVerticalMedianButtonPadding,
            Expanded(
              child: OutlinedButton(
                  style: Theme.of(context).outlinedButtonTheme.style,
                  child: Text(
                    rightButtonContent,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.visible,
                  ),
                  onPressed: () async {
                    rightButtonFunction();
                  }),
            ),
            defaultDialogPadding,
          ],
        ),
        defaultDialogLowerButtonPadding,
      ],
    );
  }
}
