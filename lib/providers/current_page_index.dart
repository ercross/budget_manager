import 'package:flutter/widgets.dart';

class CurrentPageIndex with ChangeNotifier{
  int value = 0;

  void changeValue (int newValue) {
    value = newValue;
    notifyListeners();
  }
}