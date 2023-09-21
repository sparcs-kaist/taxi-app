import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:taxiapp/constants/theme.dart';

void removeOverlayNotification(OverlayEntry? overlayEntry) {
  overlayEntry?.remove();
  overlayEntry = null;
}

void removeAnimation(AnimationController _aniController) {
  _aniController.reverse(); //TODO: 일정 dy 미만시 배너 삭제 취소 및 애니메이션 다시 재생
}

void createOverlayNotification({
  required String title,
  required String subTitle,
  required String content,
  required Map<String, Uri> button,
  OverlayEntry? overlayEntry,
  required BuildContext context,
  required ValueNotifier<String> url,
  required ValueNotifier<int> LoadCount,
  Uri? imageUrl,
}) {
  if (overlayEntry != null) {
    removeOverlayNotification(overlayEntry);
  }
  assert(overlayEntry == null);
  AnimationController aniController =
      useAnimationController(duration: const Duration(milliseconds: 300));
  Animation<Offset> animation;

  overlayEntry = OverlayEntry(builder: (BuildContext context) {
    aniController.reset();
    animation = Tween(begin: const Offset(0, -0.5), end: const Offset(0, 0))
        .animate(
            CurvedAnimation(parent: aniController, curve: Curves.decelerate));
    aniController.forward();

    return SlideTransition(
      position: animation,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dy < -1) {
            removeAnimation(aniController);
          }
        },
        onPanEnd: (details) {
          removeOverlayNotification(overlayEntry);
        },
        child: UnconstrainedBox(
          alignment: Alignment.topCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: min(MediaQuery.of(context).size.height * 0.15, 200),
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  height: 5.0,
                  color: taxiPrimaryColor,
                ),
                Positioned(
                    left: 20,
                    top: 20,
                    child: (imageUrl != Uri.parse(""))
                        ? Image(
                            image: NetworkImage(imageUrl.toString()),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : const Padding(padding: EdgeInsets.zero)),
                Positioned(
                  left: 20 +
                      ((imageUrl != Uri.parse(""))
                          ? 60
                          : 0), // 이미지 없을 시  마진 20으로 변경
                  top: 20,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 10,
                                  ),
                        ),
                        TextSpan(
                            text: (subTitle.isNotEmpty) ? "  /  $subTitle" : "",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 10, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                Positioned(
                  left: 20 + ((imageUrl != Uri.parse("")) ? 60 : 0),
                  top: 40,
                  width: MediaQuery.of(context).size.width -
                      40 -
                      ((imageUrl != Uri.parse("")) ? 60 : 0),
                  child: Text(
                    content,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: false,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4),
                  ),
                ),
                Positioned(
                  bottom: 20 / devicePixelRatio,
                  right: 25 / devicePixelRatio,
                  child: OutlinedButton(
                      style: defaultNotificatonOutlinedButtonStyle,
                      child: Text(
                        button.keys.first,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(fontSize: 12),
                      ),
                      onPressed: () {
                        removeAnimation(aniController);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (button.values.first != Uri.parse("")) {
                            url.value = button.values.first.toString();
                            LoadCount.value += 1;
                          }
                          removeOverlayNotification(overlayEntry);
                        });
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });
  Overlay.of(context).insert(overlayEntry);
}
