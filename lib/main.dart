import 'package:budget_manager/widgets/days_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'bloc_observer.dart';
import 'bloc/expense/expense_bloc.dart';
import 'bloc/chart/chart_bloc.dart';
import 'repository/contexts_keys.dart';
import 'repository/repository.dart';
import 'theme.dart';
import 'widgets/main_drawer.dart';
import 'widgets/chart.dart';
import 'widgets/input_form.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.loadSettings();
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ExpenseBloc> (
            create: (context) => ExpenseBloc(Repository.repository)
          ),
          BlocProvider<ChartBloc> (
            create: (context) => ChartBloc())
        ],
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
      key: ScaffGlobalKey.key.scaffold,
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
                    onPressed: () => showInputFieldBoxes(context) //todo check that this context is not the cause for the inactiveconnection error
                    ),
              ),
            ),
          )
        ],
      ),
      body: _homepageBody,
        drawer: MainDrawer(),
    );
  }

  void showInputFieldBoxes(BuildContext buildContext) {
    Alert(
      closeIcon: Icon(Icons.close, color: Theme.of(buildContext).accentColor,),
      context: buildContext, 
      title: "New Expense",
      buttons: [],
      content: SingleChildScrollView(
             child: InputFields(BlocProvider.of<ExpenseBloc>(buildContext), BlocProvider.of<ChartBloc>(buildContext))),
      ).show();
  }
}

class HomePageBody extends StatelessWidget {
  HomePageBody();

  static BuildContext scaffoldBodyContext;

  @override
  Widget build(BuildContext context) {
    scaffoldBodyContext = context;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight =
        mediaQuery.size.height - statusBarHeight - appBarHeight;
    return SafeArea(
      child: Column(children: <Widget>[
        Container(
            height: displayAreaHeight * 0.33,
            child: ExpenseManagerBarChart(displayAreaHeight, Repository.repository)),
        Expanded(
          child: DaysNavigator(displayAreaHeight * 0.67)),
      ]),
    );
  }
}
