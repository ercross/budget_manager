import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/income/income_bloc.dart';
import '../cubit/budget/budget_cubit.dart';
import '../widgets/new_budget_form.dart';
import '../utils/searcher.dart';
import '../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../screens/report_screen.dart';
import '../providers/current_page_index.dart';
import '../screens/budget_screen.dart';
import '../screens/income_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../bloc/chart/chart_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../repository/contexts_keys.dart';
import '../widgets/expense_bar_chart.dart';
import '../widgets/expense_tiles.dart';
import '../widgets/input_form.dart';
import '../widgets/trackIt_drawer.dart';

class ExpensesPage extends StatelessWidget {
  static const String routeName = "/expenses";
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final CurrentPageIndex page = Provider.of<CurrentPageIndex>(context, listen: false);

    return Scaffold(
      key: ScaffGlobalKey.key.scaffold,
      appBar: AppBar(
        
        shadowColor: Theme.of(context).primaryColor,
        
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Trackit", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, ),
            onPressed: () => Searcher().search(Search.values[page.value],ScaffGlobalKey.key.scaffold.currentContext),
          ),
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
                      if (page.value == 0 || page.value == 1) return _showInputFieldBoxes(context, page.value);
                      if (page.value == 2) {
                        NewBudgetForm().buildBudgetForm(context);
                      }
                      if (page.value == 3) {

                      }
                    }),
              ),
            ),
          ),
        ],
      ),
      body: BlocProvider<MiddleNavBarCubit>(
        create: (context) => MiddleNavBarCubit(),
        child: Consumer<CurrentPageIndex>(
          builder: (_, indexProvider, __) => PageView(
            controller: _pageController,
            onPageChanged: (pageIndex) {
              indexProvider.changeValue(pageIndex);
            },
            children: [
              ExpensesPageBody(),
              IncomePage(),
              BudgetsPage(),
              ReportPage(),
            ],
          ),
        ),
      ),
      drawer: TrackItDrawer(),
      bottomNavigationBar: BottomNavBar(_pageController),
    );
  }

  void _showInputFieldBoxes(BuildContext buildContext, int pageNumber) {
    String inputFormTitle;
    switch(pageNumber) {
      case 0: inputFormTitle = "New Expense"; break;
      case 1: inputFormTitle = "New Income"; break;
      case 2: inputFormTitle = "New Budget"; break;
    }

    Alert(
      closeIcon: Icon(
        Icons.close,
        color: Theme.of(buildContext).accentColor,
      ),
      context: buildContext,
      title: inputFormTitle,
      buttons: [],
      content: InputFields(
        expenseBloc: BlocProvider.of<ExpenseBloc>(buildContext),
        chartBloc: BlocProvider.of<ChartBloc>(buildContext),
        pageNumber: pageNumber,
        incomeBloc: BlocProvider.of<IncomeBloc>(buildContext),
        budgetCubit: BlocProvider.of<BudgetCubit>(buildContext),
      ),
    ).show();
  }
}

class ExpensesPageBody extends StatelessWidget {
  ExpensesPageBody();

  static BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight = mediaQuery.size.height - statusBarHeight - appBarHeight;
    return SafeArea(
      child: Column(children: <Widget>[
        Container(
            height: displayAreaHeight * 0.33,
            child: ExpenseBarChart(displayAreaHeight)),
        Container(
          height: displayAreaHeight * 0.1,
          margin: EdgeInsets.only(bottom: 1, right: 4, left: 4),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).accentColor),
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: BlocBuilder<MiddleNavBarCubit, MiddleNavBarState>(
            builder: (_, state) {
              if (state is MiddleNavBarInitial) return state.middleNavBar;
              
              if (state is NewMiddleNavBar && state.page == MiddleNavBarOn.expensePage) {
                return state.newMiddleNavBar;
              }
              return Text("Error displaying content"); //would never be reached, anyways
            },
          ),
        ),
        Expanded(child: ExpenseTiles()),
      ]),
    );
  }
}
