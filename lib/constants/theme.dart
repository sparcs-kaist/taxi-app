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
final MaterialColor taxiPrimaryMaterialColor =
    MaterialColor(0xFF6E3678, primaryColor1);
const Color taxiPrimaryColor = Color(0xFF6E3678);
const Color taxiMainBackgroundColor = Colors.white;
const Color toastBackgroundColor = Colors.white;
const Color toastTextColor = Colors.black;
const Color notiColor = Color(0x66C8C8C8);
final Color dialogBarrierColor = Colors.black.withOpacity(0.6);

const defaultDialogButtonSize = Size(128, 43);

const defaultDialogButtonInnerPadding = EdgeInsets.only(top: 9, bottom: 10);

final defaultDialogButtonBorderRadius = BorderRadius.circular(8.0);

final defaultTaxiMarginDouble = 20.0;

final defaultTaxiMargin =
    EdgeInsets.symmetric(horizontal: defaultTaxiMarginDouble);

final defaultNotificationButtonSize = const Size(88, 24);
const defaultNotificationButtonInnerPadding =
    EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0);
final defaultNotificationButtonBorderRadius = BorderRadius.circular(30.0);

ThemeData taxiTheme() {
  final base = ThemeData(
    primarySwatch: taxiPrimaryMaterialColor,
    primaryColor: const Color(0xFF6E3678),

    //dialog 테마
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      actionsPadding: const EdgeInsets.all(10.0),
      surfaceTintColor: Colors.black,
    ),
    dialogBackgroundColor: Colors.white,

    //dialog 버튼
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0.5,
        fixedSize: defaultDialogButtonSize,
        padding: defaultDialogButtonInnerPadding,
        backgroundColor: const Color.fromARGB(255, 238, 238, 238),
        shape: RoundedRectangleBorder(
          borderRadius: defaultDialogButtonBorderRadius,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        fixedSize: defaultDialogButtonSize,
        padding: defaultDialogButtonInnerPadding,
        backgroundColor: taxiPrimaryMaterialColor,
        shape: RoundedRectangleBorder(
          borderRadius: defaultDialogButtonBorderRadius,
          side: const BorderSide(color: Colors.black),
        ),
      ),
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: Colors.white,
    ),

    //텍스트 테마
    textTheme: TextTheme(
      //Dialog 제목
      titleSmall: GoogleFonts.roboto(
          textStyle: const TextStyle(
              color: Color(0xFF323232),
              fontSize: 16,
              fontWeight: FontWeight.normal)),

      //Dialog 상세 설명
      bodySmall: GoogleFonts.roboto(
          textStyle: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 10,
              fontWeight: FontWeight.bold)),

      //Dialog Elevated 버튼 텍스트
      labelLarge: GoogleFonts.roboto(
          textStyle: const TextStyle(
              color: Color(0xFFEEEEEE),
              fontSize: 14,
              fontWeight: FontWeight.bold)),

      //Dialog Elevated 버튼 텍스트
      labelMedium: GoogleFonts.roboto(
          textStyle: const TextStyle(
              color: Color.fromARGB(255, 129, 129, 129),
              fontSize: 14,
              fontWeight: FontWeight.normal)),
      labelSmall: GoogleFonts.roboto(
          textStyle: const TextStyle(
        color: Color(0xFFEEEEEE),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      )),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6E3678),
    ),
  );
  return base;
}
