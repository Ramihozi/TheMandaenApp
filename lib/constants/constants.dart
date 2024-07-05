
import 'package:flutter/material.dart';


const lightPrimaryColor = Color(0xb3000000);
const darkPrimaryColor = Color(0xff000000);

const MaterialColor lightThemeSwatch = MaterialColor(
  0xff8A51D1,
  <int, Color>{
    50:  Color(0xff000000), //10%
    100: Color(0xE6000000), //20%
    200: Color(0xCC000000), //30%
    300: Color(0xB3000000), //40%
    400: Color(0x99000000), //50%
    500: Color(0x66000000), //60%
    600: Color(0x59000000), //70%
    700: Color(0x4D000000), //80%
    800: Color(0x1A000000), //90%
    900: Color(0xD000000), //100%
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

  static const kPrimary = Color(0xb3000000);

  static const MaterialColor kSwatchColor = const MaterialColor(
    0xffA51D1,
    const <int, Color>{
      50: const Color(0xFF000000), //10%
      100: const Color(0xe6000000), //10%
      200: const Color(0xcc000000), //10%
      300: const Color(0xb3000000), //10%
      400: const Color(0x99000000), //10%
      500: const Color(0x80000000), //10%
      600: const Color(0x66000000), //10%
      700: const Color(0x4d000000), //10%
      800: const Color(0x33000000), //10%
      900: const Color(0x1A000000), //10%
    },
  );
}