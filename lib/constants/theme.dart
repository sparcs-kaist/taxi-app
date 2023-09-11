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
double devicePixelRatio = 3.0;
const double taxiDialogPadding = 15.0;
const double taxiNotificationPadding = 20.0;
final defaultDialogUpperTitlePadding =
    Padding(padding: EdgeInsets.symmetric(vertical: 36.0 / devicePixelRatio));

final defaultDialogMedianTitlePadding =
    Padding(padding: EdgeInsets.all(6 / devicePixelRatio));

final defaultDialogLowerTitlePadding =
    Padding(padding: EdgeInsets.symmetric(vertical: 24 / devicePixelRatio));

final defaultDialogVerticalMedianButtonPadding = Padding(
    padding:
        EdgeInsets.symmetric(horizontal: taxiDialogPadding / devicePixelRatio));

final defaultDialogLowerButtonPadding = Padding(
    padding:
        EdgeInsets.only(bottom: (taxiDialogPadding / 2) / devicePixelRatio));

final defaultDialogPadding =
    Padding(padding: EdgeInsets.all(taxiDialogPadding / devicePixelRatio));

final defaultDialogButtonSize = Size(147.50, 35);

final defaultDialogButtonInnerPadding = EdgeInsets.only(top: 9, bottom: 9);

final defaultDialogButtonBorderRadius = BorderRadius.circular(8.0);

final defaultTaxiMarginDouble = 20.0;

final defaultTaxiMargin =
    EdgeInsets.symmetric(horizontal: defaultTaxiMarginDouble);

const defaultNotificationButtonSize = Size(90, 30);
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
    textTheme: const TextTheme(
      //Dialog 제목
      titleSmall: TextStyle(
          fontFamily: 'NanumSquare',
          color: Color(0xFF323232),
          fontSize: 16,
          fontWeight: FontWeight.w400),

      //Dialog 상세 설명
      bodySmall: TextStyle(
          fontFamily: 'NanumSquare_acB',
          color: Color(0xFF888888),
          fontSize: 10,
          fontWeight: FontWeight.w700),

      //Dialog Outlined 버튼 텍스트
      labelLarge: TextStyle(
          fontFamily: 'NanumSquare_acB',
          color: Color(0xFFEEEEEE),
          fontSize: 14,
          fontWeight: FontWeight.w700),

      //Dialog Elevated 버튼 텍스트
      labelMedium: TextStyle(
          fontFamily: 'NanumSquare',
          color: Color.fromARGB(255, 129, 129, 129),
          fontSize: 14,
          fontWeight: FontWeight.w400),
      labelSmall: TextStyle(
        color: Color(0xFFEEEEEE),
        fontFamily: 'NanumSquare_acB',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6E3678),
      selectedLabelStyle: TextStyle(
        fontFamily: 'NanumSquare',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'NanumSquare',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    ),
  );
  return base;
}
