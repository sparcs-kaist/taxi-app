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

//아래의 상수들은 피그마 기준 상의 패딩 픽셀과는 차이를 두고 있지만,
//이는 모바일 환경상 웹뷰와 같은 간격을 제시하기 위해 설정한 값들입니다.
const defaultDialogUpperTitlePadding = Padding(padding: EdgeInsets.all(15));

const defaultDialogMedianTitlePadding = Padding(padding: EdgeInsets.all(2));

const defaultDialogLowerTitlePadding = Padding(padding: EdgeInsets.all(10));

const defaultDialogVerticalMedianButtonPadding =
    Padding(padding: EdgeInsets.all(5));

const defaultDialogLowerButtonPadding = Padding(padding: EdgeInsets.all(3));

const defaultDialogButtonSize = Size(147.50, 35);

const defaultDialogButtonInnerPadding = EdgeInsets.only(top: 9, bottom: 10);

final defaultDialogButtonBorderRadius = BorderRadius.circular(8.0);

ThemeData buildTheme() {
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
                fontWeight: FontWeight.normal))),
  );
  return base;
}
