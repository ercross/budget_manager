import 'package:flutter/material.dart';

class BudgetManagerTheme {

  static const Map<int, Color> shades = {
    50: Color.fromRGBO(171, 39, 79, 0.1),
    100: Color.fromRGBO(171, 39, 79, 0.2),
    200: Color.fromRGBO(171, 39, 79, 0.3),
    300: Color.fromRGBO(171, 39, 79, 0.4),
    400: Color.fromRGBO(171, 39, 79, 0.5),
    500: Color.fromRGBO(171, 39, 79, 1),
    600: Color.fromRGBO(171, 39, 79, 0.6),
    700: Color.fromRGBO(171, 39, 79, 0.7),
    800: Color.fromRGBO(171, 39, 79, 0.8),
    900: Color.fromRGBO(171, 39, 79, 0.9)
  };

  static const MaterialColor primarySwatch = MaterialColor(0xFFAB274F, shades);

  ThemeData makeTheme () {
    return ThemeData(
      primarySwatch: primarySwatch,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.deepOrange,
            fontFamily: 'Quicksand',
          )
        )
    );
  }
}