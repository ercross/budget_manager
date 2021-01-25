import 'package:flutter/material.dart';

import '../widgets/report_tiles.dart';

class ReportPage extends StatelessWidget {
  static const String routeName = "/report";
  const ReportPage();

  static BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight = mediaQuery.size.height - statusBarHeight - appBarHeight;
    return Scaffold(
      body: ReportTiles(displayAreaHeight));
  }
}