import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_store/open_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      height: 165,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(15)),
            ...boxContent,
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
                    child: Text(leftButtonContent,
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFFC8C8C8),
                                fontSize: 13,
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
                    child: Text(rightButtonContent,
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFFEEEEEE),
                                fontSize: 13,
                                fontWeight: FontWeight.bold))),
                    onPressed: () async {
                      OpenStore.instance.open(
                          androidAppBundleId: dotenv.get("ANDROID_APPID"),
                          appStoreId: dotenv.get("IOS_APPID"));
                    }),
              ],
            )
          ]),
    );
  }
}
