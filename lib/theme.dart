import 'package:flutter/material.dart';

class BudgetManagerTheme {

  static const Map<int, Color> _shades = {
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

  static const MaterialColor _primarySwatch = MaterialColor(0xFFAB274F, _shades);

  ThemeData makeTheme () {
    return ThemeData(
      primarySwatch: _primarySwatch,
      accentColor: Colors.deepOrange,
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyText2: TextStyle(
            color: Colors.deepOrange,
            fontSize: 16,
            fontFamily: 'OpenSans'
          )
        ),
        
    );
  }
}