import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//primaryColor 지정 (색상코드: #6E3647)
final Map<int, Color> primaryColor1 = {
  50: const Color.fromRGBO(110, 54, 120, .1),
  100: const Color.fromRGBO(110, 54, 120, .2),
  200: const Color.fromRGBO(110, 54, 120, .3),
  300: const Color.fromRGBO(110, 54, 120, .4),
  400: const Color.fromRGBO(110, 54, 120, .5),
  500: const Color.fromRGBO(110, 54, 120, .6),
  600: const Color.fromRGBO(110, 54, 120, .7),
  700: const Color.fromRGBO(110, 54, 120, .8),
  800: const Color.fromRGBO(110, 54, 120, .9),
  900: const Color.fromRGBO(110, 54, 120, 1),
};
MaterialColor taxiPrimaryColor = MaterialColor(0xFF6E3678, primaryColor1);

ThemeData buildTheme() {
  final base = ThemeData(
    primarySwatch: taxiPrimaryColor,
    primaryColor: const Color(0xFF6E3678),
    textTheme: TextTheme(
        //Dialog 제목
        titleMedium: GoogleFonts.roboto(
            textStyle: const TextStyle(
                color: Color(0xFF323232),
                fontSize: 22,
                fontWeight: FontWeight.normal)),

        //Dialog 상세 설명
        bodySmall: GoogleFonts.roboto(
            textStyle: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.bold)),

        //Dialog Elevated 버튼 텍스트
        labelLarge: GoogleFonts.roboto(
            textStyle: const TextStyle(
                color: Color(0xFFEEEEEE),
                fontSize: 13,
                fontWeight: FontWeight.bold)),

        //Dialog Elevated 버튼 텍스트
        labelMedium: GoogleFonts.roboto(
            textStyle: const TextStyle(
                color: Color(0xFFC8C8C8),
                fontSize: 13,
                fontWeight: FontWeight.normal))),
  );
  return base;
}
