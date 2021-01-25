import 'package:flutter/material.dart';

class BudgetManagerTheme {

  // static const Map<int, Color> _shades = {
  //   50: Color.fromRGBO(171, 39, 79, 0.1),
  //   100: Color.fromRGBO(171, 39, 79, 0.2),
  //   200: Color.fromRGBO(171, 39, 79, 0.3),
  //   300: Color.fromRGBO(171, 39, 79, 0.4),
  //   400: Color.fromRGBO(171, 39, 79, 0.5),
  //   500: Color.fromRGBO(171, 39, 79, 1),
  //   600: Color.fromRGBO(171, 39, 79, 0.6),
  //   700: Color.fromRGBO(171, 39, 79, 0.7),
  //   800: Color.fromRGBO(171, 39, 79, 0.8),
  //   900: Color.fromRGBO(171, 39, 79, 0.9)
  // };

  static const Map<int, Color> _shades = {
    50: Color(0xa2a200),
    100: Color(0x520160),
    200: Color(0x520160),
    300: Color(0x520160),
    400: Color(0x520160),
    500: Color(0x520160),
    600: Color(0x520160),
    700: Color(0x520160),
    800: Color(0x520160),
    900: Color(0x520160),
  };

  static const MaterialColor _primarySwatch = MaterialColor(0xFF520160, _shades);

  ThemeData makeTheme () {
    return ThemeData(
      primarySwatch: _primarySwatch,
      appBarTheme: AppBarTheme(textTheme: TextTheme(headline6:TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontFamily: 'Pacifico'
          ),)),
      accentColor: Colors.green,
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyText2: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontFamily: 'FugazOne'
          ), 
        )
    );
  }
}