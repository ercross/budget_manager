import 'package:budget_manager/bloc_observer.dart';
import 'package:budget_manager/repository/database_provider.dart';
import 'package:budget_manager/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './theme.dart';
import './widgets/chart.dart';
import './widgets/expense_list.dart';
import './bloc/expense_bloc.dart';
import 'widgets/input_form.dart';


void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      home: BlocProvider(
        create: (context) => ExpenseBloc(DatabaseProvider.databaseProvider),
        child: MyHomePage(),
      ),
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
                    onPressed: () => showInputFieldBoxes(context)
                    ),
              ),
            ),
          )
        ],
      ),
      body: _homepageBody,
    );
  }

  void showInputFieldBoxes(BuildContext buildContext) {
    showModalBottomSheet(
        context: buildContext,
        builder: (context) {
          return SingleChildScrollView(child: InputFields(BlocProvider.of<ExpenseBloc>(buildContext)));
        });
  }
}

class HomePageBody extends StatelessWidget {
  const HomePageBody();

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
            child: ExpenseManagerBarChart(displayAreaHeight)),
        Expanded(
          child: Container(
              height: displayAreaHeight * 0.7, child: ExpenseList()),
        ),
      ]),
    );
  }
}
