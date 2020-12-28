import 'package:flutter/material.dart';

class ScaffGlobalKey {
  GlobalKey _scaffoldKey;

  ScaffGlobalKey._() : _scaffoldKey = GlobalKey();

  static final ScaffGlobalKey key = ScaffGlobalKey._();

  GlobalKey get scaffold => _scaffoldKey;
}