import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//primaryColor 지정 (색상코드: #6E3647)
final Map<int, Color> primaryColor1 = {
  50: const Color.fromRGBO(110, 54, 71, .1),
  100: const Color.fromRGBO(110, 54, 71, .2),
  200: const Color.fromRGBO(110, 54, 71, .3),
  300: const Color.fromRGBO(110, 54, 71, .4),
  400: const Color.fromRGBO(110, 54, 71, .5),
  500: const Color.fromRGBO(110, 54, 71, .6),
  600: const Color.fromRGBO(110, 54, 71, .7),
  700: const Color.fromRGBO(110, 54, 71, .8),
  800: const Color.fromRGBO(110, 54, 71, .9),
  900: const Color.fromRGBO(110, 54, 71, 1),
};
MaterialColor taxiPrimaryColor = MaterialColor(0xFF6E3647, primaryColor1);

ThemeData buildTheme() {
  final base = ThemeData(
    primarySwatch: taxiPrimaryColor,
    primaryColor: const Color(0xFF6E3647),
    textTheme: TextTheme(
      //Dialog 제목 강조
      titleMedium: GoogleFonts.roboto(
          textStyle: const TextStyle(
              color: Color(0xFF323232),
              fontSize: 22,
              fontWeight: FontWeight.normal)),

      //Dialog 상세 추가 설명
      bodySmall: GoogleFonts.roboto(
          textStyle: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    ),
  );
  return base;
}
