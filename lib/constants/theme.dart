import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  final base = ThemeData(
    primarySwatch: Colors.blue,
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
