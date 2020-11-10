import 'package:flutter/material.dart';

import './theme.dart';
import './widgets/chart.dart';
import './widgets/expense_list.dart';
import './vanilla_bloc/expense_bloc.dart';
import 'widgets/input_form.dart';

/*  */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      home: MyHomePage(),
      theme: BudgetManagerTheme().makeTheme(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomePageBody _homepageBody = new HomePageBody();

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Manager'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: FittedBox(
                child: IconButton(
                    icon: Icon(Icons.add),
                    color: Theme.of(context).primaryColor,
                    highlightColor: Theme.of(context).accentColor,
                    iconSize: 50,
                    onPressed: () {
                      _homepageBody.showInputFieldBoxes(context);
                    }),
              ),
            ),
          )
        ],
      ),
      body: _homepageBody,
    );
  }
}

class HomePageBody extends StatelessWidget {
  final ExpenseBloc _expenseBloc = ExpenseBloc();

  HomePageBody();

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight =
        mediaQuery.size.height - statusBarHeight - appBarHeight;

    return SafeArea(
      child: Column(children: <Widget>[
        Container(
            height: displayAreaHeight * 0.35,
            child: ExpenseManagerBarChart(displayAreaHeight, _expenseBloc.expenses)),
        Expanded(
          child: Container(
              height: displayAreaHeight * 0.7,
              child: ExpenseList(expenseBloc: _expenseBloc)),
        ),
      ]),
    );
  }

  void showInputFieldBoxes(BuildContext buildContext) {
    showModalBottomSheet(
        context: buildContext,
        builder: (_) {
          return SingleChildScrollView(child: InputFields(_expenseBloc));
        });
  }
}
