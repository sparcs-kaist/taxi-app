import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaxiDialog extends StatelessWidget {
  const TaxiDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 165,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(15)),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "새로운 ",
                  style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Color(0xFF323232),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  children: <TextSpan>[
                    TextSpan(text: "버전"),
                    TextSpan(
                        text: "이 ",
                        style: TextStyle(fontWeight: FontWeight.normal)),
                    TextSpan(
                        text: "출시", style: TextStyle(color: Color(0xFF6E3678))),
                    TextSpan(
                        text: "되었습니다!",
                        style: TextStyle(fontWeight: FontWeight.normal))
                  ]),
            ),
            Text("정상적인 사용을 위해 앱을 업데이트 해주세요.",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 8,
                        fontWeight: FontWeight.bold))),
            const Padding(
              padding: EdgeInsets.all(15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.5,
                      fixedSize: const Size(150, 45),
                      backgroundColor: const Color(0xFFFAF8FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                    child: Text("앱 종료하기",
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFFC8C8C8),
                                fontSize: 15,
                                fontWeight: FontWeight.normal))),
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
                      fixedSize: MaterialStateProperty.all(const Size(150, 45)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF6E3678)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text("업데이트 하러가기",
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFFEEEEEE),
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                    onPressed: () async {
                      LaunchReview.launch(
                          androidAppId: dotenv.get("ANDROID_APPID"),
                          iOSAppId: dotenv.get("IOS_APPID"));
                    }),
              ],
            )
          ]),
    );
  }
}
