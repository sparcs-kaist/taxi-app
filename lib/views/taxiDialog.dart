import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';

class TaxiDialog extends StatelessWidget {
  const TaxiDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("새로운 버전이 출시되었습니다!",
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 15,
                        fontWeight: FontWeight.bold))),
            Row(
              children: [
                OutlinedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250, 45)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF6E3678)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text("업데이트 하러가기",
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                    onPressed: () async {}),
                OutlinedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(250, 45)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFFFAF8FB)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text("앱 종료하기",
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                                color: Color(0xFFEEEEEE),
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                    onPressed: () async {}),
              ],
            )
          ]),
    );
  }
}
