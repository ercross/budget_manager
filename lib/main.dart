import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './providers/current_page_index.dart';
import 'bloc/chart/chart_bloc.dart';
import 'bloc/expense/expense_bloc.dart';
import 'bloc_observer.dart';
import 'repository/repository.dart';
import 'screens/search_result_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/income_screen.dart';
import 'theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.loadSettings();
  Bloc.observer = SimpleBlocObserver();
  runApp(TrackIt());
}

class TrackIt extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackIt',
      home: ChangeNotifierProvider(create: (ctx) => CurrentPageIndex(),
        child:MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(Repository.repository)),
        BlocProvider<ChartBloc>(
          create: (context) => ChartBloc(),
        ),
      ],
      child: ExpensesPage()
      ),),
      theme: BudgetManagerTheme().makeTheme(),
      routes: {
        ExpensesPage.routeName: (ctx) => ExpensesPage(),
        SearchResultPage.routeName: (ctx) => SearchResultPage(),
        IncomePage.routeName: (ctx) => IncomePage(),
        BudgetsPage.routeName: (ctx) => BudgetsPage(),
      },
    );
  }
}