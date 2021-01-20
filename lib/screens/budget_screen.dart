import 'package:flutter/material.dart';
import 'package:trackIt/widgets/budget_tiles.dart';

class BudgetsPage extends StatelessWidget {

  static const String routeName = "/budgets";

  const BudgetsPage();

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight = mediaQuery.size.height - statusBarHeight - appBarHeight;

    return Scaffold(
      body: BudgetTiles(displayAreaHeight),
    );
  }
}