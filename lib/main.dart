import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './cubit/budget/budget_cubit.dart';
import './screens/report_screen.dart';
import './providers/current_page_index.dart';
import 'bloc/chart/chart_bloc.dart';
import 'bloc/expense/expense_bloc.dart';
import 'bloc/income/income_bloc.dart';
import 'bloc_observer.dart';
import 'cubit/report/report_cubit.dart';
import 'repository/repository.dart';
import 'screens/search_result_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/income_screen.dart';
import 'theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Preferences.loadSettings();
  await ReportCubit.initReports();
  Bloc.observer = SimpleBlocObserver();
  runApp(Trackit());
}

class Trackit extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
      child: MaterialApp(
        title: 'Trackit',
        home: ChangeNotifierProvider(create: (ctx) => CurrentPageIndex(),
          child:MultiBlocProvider(
        providers: [
          BlocProvider<ExpenseBloc>(
              create: (context) => ExpenseBloc(Repository.repository)),
          BlocProvider<ChartBloc>(
            create: (context) => ChartBloc()),
          BlocProvider<IncomeBloc>(
            create: (context) => IncomeBloc()),
          BlocProvider<ReportCubit>(
            create: (context) => ReportCubit()),
          BlocProvider<BudgetCubit>(
            create: (context) => BudgetCubit()),
        ],
        child: ExpensesPage()
        ),),
        theme: BudgetManagerTheme().makeTheme(),
        routes: {
          ExpensesPage.routeName: (ctx) => ExpensesPage(),
          SearchResultPage.routeName: (ctx) => SearchResultPage(),
          IncomePage.routeName: (ctx) => IncomePage(),
          BudgetsPage.routeName: (ctx) => BudgetsPage(),
          ReportPage.routeName: (ctx) => ReportPage(),
        },
      ),
    );
  }
}