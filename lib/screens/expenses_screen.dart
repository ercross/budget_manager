import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackIt/cubit/middlenavbar_cubit.dart';
import 'package:trackIt/widgets/middle_nav_bar.dart';

import '../providers/current_page_index.dart';
import '../screens/budgets_screen.dart';
import '../screens/income_screen.dart';
import '../screens/search_result_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../bloc/chart/chart_bloc.dart';
import '../bloc/expense/expense_bloc.dart';
import '../repository/contexts_keys.dart';
import '../widgets/chart.dart';
import '../widgets/expense_list.dart';
import '../widgets/input_form.dart';
import '../widgets/main_drawer.dart';
import '../repository/repository.dart';

class ExpensesPage extends StatelessWidget {
  static const String routeName = "/expenses";
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    Provider.of<CurrentPageIndex>(context, listen: false);

    return Scaffold(
      key: ScaffGlobalKey.key.scaffold,
      appBar: AppBar(
        title: Text("trackIt"),
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
                    onPressed: () => _showInputFieldBoxes(context)),
              ),
            ),
          )
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
              SearchResultPage(),
            ],
          ),
        ),
      ),
      drawer: MainDrawer(),
      bottomNavigationBar: BottomNavBar(_pageController),
    );
  }

  void _showInputFieldBoxes(BuildContext buildContext) {
    Alert(
      closeIcon: Icon(
        Icons.close,
        color: Theme.of(buildContext).accentColor,
      ),
      context: buildContext,
      title: "New Expense",
      buttons: [],
      content: SingleChildScrollView(
          child: InputFields(
        BlocProvider.of<ExpenseBloc>(buildContext),
        BlocProvider.of<ChartBloc>(buildContext),
      )),
    ).show();
  }
}

class ExpensesPageBody extends StatelessWidget {
  ExpensesPageBody();

  static BuildContext expensesScreenContext;

  @override
  Widget build(BuildContext context) {
    expensesScreenContext = context;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;
    final double appBarHeight = AppBar().preferredSize.height;
    final double displayAreaHeight =
        mediaQuery.size.height - statusBarHeight - appBarHeight;
    return SafeArea(
      child: Column(children: <Widget>[
        Container(
            height: displayAreaHeight * 0.33,
            child: ExpenseManagerBarChart(
                displayAreaHeight, Repository.repository)),
        Container(
          height: displayAreaHeight * 0.1,
          margin: EdgeInsets.only(bottom: 1, right: 8, left: 8),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).accentColor),
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: BlocBuilder<MiddleNavBarCubit, MiddleNavBarState>(
            builder: (_, state) {
              if (state is MiddleNavBarInitial) {
                return state.middleNavBar;
              }
              if (state is NewMiddleNavBar) {
                return state.newMiddleNavBar;
              }
              return null; //would never be reached, anyways
            },
          ),
        ),
        Expanded(child: ExpenseList()),
      ]),
    );
  }
}
