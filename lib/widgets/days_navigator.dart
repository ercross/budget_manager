import 'package:budget_manager/bloc/expense/expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../models/expense.dart';
import 'day_nav_bar.dart';
import 'expense_list.dart';

class DaysNavigator extends StatefulWidget {

  //these fields are static, non-final to enable update of the fields from inside the nav_bar
  static List<Expense> oldestDayExpenses;
  static List<Expense> previousDayExpenses;
  static List<Expense> expenseListOnDisplay;
  static List<Expense> nextDayExpenses;
  static List<Expense> todaysExpenses;
  bool enableOldestDateButton;
  bool enablePreviousDayButton;
  bool enableNextDayButton;
  bool enableTodayButton;
  DateTime currentDate;

  ///availableHeight is the height of the viewport available to display this widget
  final double availableHeight;

  DaysNavigator(this.availableHeight);

  @override
  _DaysNavigatorState createState() => _DaysNavigatorState();
}

class _DaysNavigatorState extends State<DaysNavigator> {

  @override
  void initState() { 
    super.initState();
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime previousDay = todaysDate.subtract(Duration(days: 1));
    widget.currentDate = DateTime.now();

    Repository.repository.batchGet (ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", 
      [Repository.repository.oldestDate, previousDay, todaysDate]).then((expensesList) {
        DaysNavigator.oldestDayExpenses = expensesList[0];
        DaysNavigator.previousDayExpenses = expensesList[1];
        DaysNavigator.todaysExpenses = expensesList[2];
        DaysNavigator.expenseListOnDisplay = DaysNavigator.todaysExpenses;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container (
            height: widget.availableHeight * 0.15,
            margin: EdgeInsets.only(bottom: 1, right: 8, left: 8),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).accentColor),
              borderRadius: BorderRadius.all(Radius.circular(6))
            ),
            child: _navBar,
        ),
        Expanded(
          child: GestureDetector(
            child: Container(
                child: ExpenseList(DaysNavigator.todaysExpenses), 
                margin: EdgeInsets.all(5)
                ),
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if(details.delta.dx < 0) {
              _onLeftSwipe(context);
            }

            if (details.delta.dx > 0) {
              _onRightSwipe(context);
            }
          },
          ),
        ),
      ],);
  }

  //_navBar is extracted out here so its value can be reset depending on gestures on the expense list
  DaysNavBar _navBar = DaysNavBar(
              currentDate: DateTime.now(),
              enableOldestDateButton: true,
              enablePreviousDayButton: true,
            );

  void _onLeftSwipe(BuildContext ctx) async {
    
    if (widget.currentDate.subtract(Duration(days: 1)).isBefore(Repository.repository.oldestDate)){
      return;
    }
  
    if (widget.currentDate.isAtSameMomentAs(Repository.repository.oldestDate)) {
        widget.enableOldestDateButton = false;
        widget.enablePreviousDayButton = false;
        widget.enableNextDayButton = true;
        widget.enableTodayButton = true;
    } 
    else {
      widget.enableOldestDateButton = true;
      widget.enablePreviousDayButton = true;
      widget.enableTodayButton = true;
      widget.enableNextDayButton = true;
    }

    final DateTime previousDayDate = DateTime(widget.currentDate.year, widget.currentDate.month, widget.currentDate.day)
      
          //2 days substracted because the current previousDate in memory would be expenseListOnDisplay, i.e currentDate-oneDay
          //and the previousDay after that is currentDate-twoDays
                                  .subtract(Duration(days:2));

    DaysNavigator.nextDayExpenses = DaysNavigator.expenseListOnDisplay;
    DaysNavigator.expenseListOnDisplay = DaysNavigator.previousDayExpenses;
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpenses(DaysNavigator.expenseListOnDisplay));
    DaysNavigator.previousDayExpenses = await Repository.repository.getAll(
          ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [previousDayDate.millisecondsSinceEpoch]);

    widget.currentDate = widget.currentDate.subtract(Duration(days: 1));
    setState(() {
      _navBar = DaysNavBar(
        currentDate: widget.currentDate,
        enableOldestDateButton: widget.enableOldestDateButton,
        enablePreviousDayButton: widget.enablePreviousDayButton,
        enableNextDayButton: widget.enableNextDayButton,
        enableTodayButton: widget.enableTodayButton,);
    });
  }

  void _onRightSwipe(BuildContext ctx) async {
    if (widget.currentDate.add(Duration(days: 1)).isAfter(DateTime.now())){
      return;
    }
  
    if (widget.currentDate.isAtSameMomentAs(DateTime (DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
        widget.enableOldestDateButton = true;
        widget.enablePreviousDayButton = true;
        widget.enableNextDayButton = false;
        widget.enableTodayButton = false;
    } 
    else {
      widget.enableOldestDateButton = true;
      widget.enablePreviousDayButton = true;
      widget.enableTodayButton = true;
      widget.enableNextDayButton = true;
    }

    final DateTime nextDayDate = DateTime(widget.currentDate.year, widget.currentDate.month, widget.currentDate.day)

              //2 days added because the current nextDate in memory would have become expenseListOnDisplay, i.e currentDate+oneDay
                            .add(Duration(days: 2));

      DaysNavigator.previousDayExpenses = DaysNavigator.expenseListOnDisplay;
      DaysNavigator.expenseListOnDisplay = DaysNavigator.nextDayExpenses;
      BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpenses(DaysNavigator.expenseListOnDisplay));
      DaysNavigator.nextDayExpenses = await Repository.repository.getAll(
          ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [nextDayDate.millisecondsSinceEpoch]);

    setState(() {
      _navBar = DaysNavBar(
        currentDate: widget.currentDate,
        enableOldestDateButton: widget.enableOldestDateButton,
        enablePreviousDayButton: widget.enablePreviousDayButton,
        enableNextDayButton: widget.enableNextDayButton,
        enableTodayButton: widget.enableTodayButton,);         
    });
  }
}