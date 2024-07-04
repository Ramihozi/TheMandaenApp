
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter/material.dart';

const lightPrimaryColor = Color(0xff8a51d1);
const darkPrimaryColor = Color(0xff000000);

const MaterialColor lightThemeSwatch = MaterialColor(
  0xff8A51D1,
  <int, Color>{
    50:  Color(0xff9662d6), //10%
    100: Color(0xffa174da), //20%
    200: Color(0xffad85df), //30%
    300: Color(0xffb997e3), //40%
    400: Color(0xffc5a8e8), //50%
    500: Color(0xffd0b9ed), //60%
    600: Color(0xffdccbf1), //70%
    700: Color(0xffe8dcf6), //80%
    800: Color(0xfff3eefa), //90%
    900: Color(0xffffffff), //100%
  },
);
const MaterialColor darkThemeSwatch = MaterialColor(
  0xff000000,
  <int, Color>{
    50:  Color(0xff000000), //10%
    100: Color(0xE6000000), //20%
    200: Color(0xcc000000), //30%
    300: Color(0xB3000000), //40%
    400: Color(0x99000000), //50%
    500: Color(0x80000000), //60%
    600: Color(0x66000000), //70%
    700: Color(0x4D000000), //80%
    800: Color(0x33000000), //90%
    900: Color(0x1A000000), //100%
  },
);
class Constants {

  static const kPrimary = Color(0xff8a51d1);

  static const MaterialColor kSwatchColor = const MaterialColor(
    0xffA51D1,
    const <int, Color>{
      50: const Color(0xff9662d6), //10%
      100: const Color(0xffa174da), //10%
      200: const Color(0xffad85df), //10%
      300: const Color(0xffb997e3), //10%
      400: const Color(0xffc5a8e8), //10%
      500: const Color(0xffd0b9ed), //10%
      600: const Color(0xffdccbf1), //10%
      700: const Color(0xffe8dcf6), //10%
      800: const Color(0xfff3eefa), //10%
      900: const Color(0xffffffff), //10%
    },
  );
}