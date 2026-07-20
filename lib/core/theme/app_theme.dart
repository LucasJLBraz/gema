import 'package:flutter/material.dart';

abstract final class GemaColors {
  // Light
  static const lightBg = Color(0xFFF6F4F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVar = Color(0xFFEBE3D8);
  static const lightSurfaceEmph = Color(0xFFF0EDE8);
  static const lightPrimary = Color(0xFFB3700C);
  static const lightPrimaryCont = Color(0xFFFDDEA3);
  static const lightOnPrimCont = Color(0xFF3A1F00);
  static const lightSecondary = Color(0xFF665940);
  static const lightSecondaryCont = Color(0xFFF2E5CC);
  static const lightOnSecCont = Color(0xFF221A0A);
  static const lightText = Color(0xFF1A1814);
  static const lightTextSub = Color(0xFF4A3F32);
  static const lightTextDis = Color(0xFF9A8E80);
  static const lightOutline = Color(0xFFBEB0A0);
  static const lightOutlineVar = Color(0xFFE6DDD2);
  static const lightDivider = Color(0xFFEBE3D8);
  static const lightError = Color(0xFFB3261E);
  static const lightErrorCont = Color(0xFFFFDAD6);
  static const lightOnErrCont = Color(0xFF410002);
  static const lightSuccess = Color(0xFF386A20);
  static const lightSuccessCont = Color(0xFFC2F099);

  // Dark
  static const darkBg = Color(0xFF131110);
  static const darkSurface = Color(0xFF1C1916);
  static const darkSurfaceVar = Color(0xFF282320);
  static const darkSurfaceEmph = Color(0xFF222018);
  static const darkPrimary = Color(0xFFF4BA52);
  static const darkPrimaryCont = Color(0xFF472F00);
  static const darkOnPrimCont = Color(0xFFFDDEA3);
  static const darkSecondary = Color(0xFFCDB998);
  static const darkSecondaryCont = Color(0xFF3A2E1C);
  static const darkOnSecCont = Color(0xFFF2E5CC);
  static const darkText = Color(0xFFEDE4D8);
  static const darkTextSub = Color(0xFFA8957E);
  static const darkTextDis = Color(0xFF5A5048);
  static const darkOutline = Color(0xFF38302A);
  static const darkOutlineVar = Color(0xFF2A2420);
  static const darkDivider = Color(0xFF282320);
  static const darkError = Color(0xFFFFB4AB);
  static const darkErrorCont = Color(0xFF93000A);
  static const darkOnErrCont = Color(0xFFFFDAD6);
  static const darkSuccess = Color(0xFF86C278);
  static const darkSuccessCont = Color(0xFF1A4A0A);

  // Chart — semantic, mode-aware
  static const chartKcalLight = Color(0xFFB3700C);
  static const chartProteinLight = Color(0xFF2E8B7A);
  static const chartCarbsLight = Color(0xFF5C7EB0);
  static const chartFatLight = Color(0xFFB86840);
  static const chartKcalDark = Color(0xFFF4BA52);
  static const chartProteinDark = Color(0xFF5EC9B8);
  static const chartCarbsDark = Color(0xFF87AEDC);
  static const chartFatDark = Color(0xFFE4916A);
}

abstract final class GemaTextStyles {
  static const _font = 'PlusJakartaSans';
  static const _mono = 'DMMono';

  static const display = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    height: 1.1,
  );
  static const headline = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const title = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  static const body = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );
  static const label = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6,
  );
  static const micro = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
  );
  static const dataMono = TextStyle(
    fontFamily: _mono,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}

ThemeData buildTheme({required bool dark}) {
  final bg = dark ? GemaColors.darkBg : GemaColors.lightBg;
  final surface = dark ? GemaColors.darkSurface : GemaColors.lightSurface;
  final primary = dark ? GemaColors.darkPrimary : GemaColors.lightPrimary;
  final onPrimary = dark ? const Color(0xFF2A1800) : Colors.white;
  final text = dark ? GemaColors.darkText : GemaColors.lightText;
  final textSub = dark ? GemaColors.darkTextSub : GemaColors.lightTextSub;
  final outline = dark ? GemaColors.darkOutline : GemaColors.lightOutline;

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: dark ? GemaColors.darkSecondary : GemaColors.lightSecondary,
      onSecondary: dark ? GemaColors.darkOnSecCont : GemaColors.lightOnSecCont,
      error: dark ? GemaColors.darkError : GemaColors.lightError,
      onError: dark ? GemaColors.darkOnErrCont : GemaColors.lightOnErrCont,
      surface: surface,
      onSurface: text,
    ),
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      titleTextStyle: GemaTextStyles.title.copyWith(color: text),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: dark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: dark
            ? const BorderSide(color: GemaColors.darkOutlineVar)
            : BorderSide.none,
      ),
    ),
    dividerColor: dark ? GemaColors.darkDivider : GemaColors.lightDivider,
    textTheme: TextTheme(
      displayLarge: GemaTextStyles.display.copyWith(color: text),
      headlineMedium: GemaTextStyles.headline.copyWith(color: text),
      titleMedium: GemaTextStyles.title.copyWith(color: text),
      bodyMedium: GemaTextStyles.body.copyWith(color: textSub),
      labelLarge: GemaTextStyles.label.copyWith(color: text),
      labelSmall: GemaTextStyles.caption.copyWith(color: textSub),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? GemaColors.darkSurfaceVar : GemaColors.lightSurfaceVar,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        textStyle: GemaTextStyles.label,
      ),
    ),
  );
}
