import 'package:flutter/material.dart';

import '../widgets/budget_tiles.dart';

class BudgetsPage extends StatelessWidget {

  static const String routeName = "/budgets";

  const BudgetsPage();

  static BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight = mediaQuery.size.height - statusBarHeight - appBarHeight;

    return Scaffold(
      body: BudgetTiles(displayAreaHeight),
    );
  }
}