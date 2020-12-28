import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/expense/expense_bloc.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../widgets/days_navigator.dart';

class DaysNavBar extends StatefulWidget {

  bool enableOldestDateButton;
  bool enablePreviousDayButton;
  bool enableNextDayButton;
  bool enableTodayButton;
  DateTime currentDate;

  DaysNavBar({
    this.enableOldestDateButton = false, 
    this.enablePreviousDayButton = false, 
    this.enableNextDayButton = false, 
    this.enableTodayButton = false,
    @required this.currentDate});

  @override
  _DaysNavBarState createState() => _DaysNavBarState();
}

class _DaysNavBarState extends State<DaysNavBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildNavIcon(
          ctx: context, 
          enableButton: widget.enableOldestDateButton, 
          icon: Icons.fast_rewind_outlined, 
          onTap: () => _onOldestDateButtonPressed(context)),
        
        _buildNavIcon (
          ctx: context,
          enableButton: widget.enablePreviousDayButton,
          icon: Icons.arrow_left_outlined,
          onTap: () => _onPreviousButtonPressed(context)),

        Expanded(child: FittedBox(
          child: Text(DateFormat('EEE MMM d, yyyy').format(widget.currentDate), style: TextStyle(color: Theme.of(context).accentColor, fontSize: 18, fontWeight: FontWeight.bold),))),

        _buildNavIcon (
          ctx: context,
          enableButton: widget.enableNextDayButton,
          icon: Icons.arrow_right_outlined,
          onTap: () => _onNextButtonPressed(context)),

        _buildNavIcon (
          ctx: context,
          enableButton: widget.enableTodayButton,
          icon: Icons.fast_forward_outlined,
          onTap: () => _onTodayButtonPressed(context)),
      ],
    );
  }

  Widget _buildNavIcon({
    @required bool enableButton, 
    @required Function onTap,
    @required IconData icon,
    @required BuildContext ctx,
    double size = 50}) {

      if (enableButton) {
        return GestureDetector(
          child: Icon (icon, size: size, color: Theme.of(ctx).primaryColor,),
          onTap: onTap,
        );
      }
      return Icon(icon, size: size, color: Colors.grey,);
    }

    void _onTodayButtonPressed(BuildContext ctx) async {
      final DateTime previousDayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days:1));
      DaysNavigator.previousDayExpenses = await Repository.repository.getAll(ExpenseTable.tableName, 
          where: "${ExpenseTable.columnDate}=?", whereArgs:[previousDayDate.millisecondsSinceEpoch]);
      DaysNavigator.expenseListOnDisplay = DaysNavigator.todaysExpenses;
      BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpenses(DaysNavigator.expenseListOnDisplay));

      setState(() {
        widget.enableTodayButton = false;
        widget.enableNextDayButton = false;
        widget.enableOldestDateButton = true;
        widget.enablePreviousDayButton = true;
        widget.currentDate = DateTime.now();
      });
    }

    void _onOldestDateButtonPressed (BuildContext ctx) async {
      DaysNavigator.nextDayExpenses = await Repository.repository.getAll(ExpenseTable.tableName, 
              where: "${ExpenseTable.columnDate}=?", whereArgs:[Repository.repository.oldestDate.add(Duration(days:1)).millisecondsSinceEpoch]);
      DaysNavigator.expenseListOnDisplay = DaysNavigator.oldestDayExpenses;
      BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpenses(DaysNavigator.expenseListOnDisplay));
      setState((){
        widget.currentDate = Repository.repository.oldestDate;
        widget.enableOldestDateButton = false;
        widget.enablePreviousDayButton = false;
        widget.enableTodayButton = true;
        widget.enableNextDayButton =true;
      });
    }

    void _onPreviousButtonPressed(BuildContext ctx) async {
      final DateTime previousDayDate = DateTime(widget.currentDate.year, widget.currentDate.month, widget.currentDate.day)
      
          //2 days substracted because the current previousDate in memory would be expenseListOnDisplay, i.e currentDate-oneDay
          //and the previousDay after that is currentDate-twoDays
                                  .subtract(Duration(days:2));

      DaysNavigator.nextDayExpenses = DaysNavigator.expenseListOnDisplay;
      DaysNavigator.expenseListOnDisplay = DaysNavigator.previousDayExpenses;
      BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpenses(DaysNavigator.expenseListOnDisplay));
      DaysNavigator.previousDayExpenses = await Repository.repository.getAll(
          ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [previousDayDate.millisecondsSinceEpoch]);
      
      setState(() {
        widget.currentDate = widget.currentDate.subtract(Duration(days: 1));
        widget.currentDate = DateTime(widget.currentDate.year, widget.currentDate.month, widget.currentDate.day);
        if (widget.currentDate.isAtSameMomentAs(Repository.repository.oldestDate)) {
          widget.enableOldestDateButton = false;
          widget.enablePreviousDayButton = false;
          widget.enableTodayButton = true;
          widget.enableNextDayButton = true;
        }
      });
    }

    void _onNextButtonPressed(BuildContext ctx) async {
      final DateTime nextDayDate = DateTime(widget.currentDate.year, widget.currentDate.month, widget.currentDate.day)

              //2 days added because the current nextDate in memory would have become expenseListOnDisplay, i.e currentDate+oneDay
                            .add(Duration(days: 2));

      DaysNavigator.previousDayExpenses = DaysNavigator.expenseListOnDisplay;
      DaysNavigator.expenseListOnDisplay = DaysNavigator.nextDayExpenses;
      BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpenses(DaysNavigator.expenseListOnDisplay));
      DaysNavigator.nextDayExpenses = await Repository.repository.getAll(
          ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [nextDayDate.millisecondsSinceEpoch]);

      setState(() {
        widget.currentDate = widget.currentDate.add(Duration(days: 1));
        widget.currentDate = DateTime(widget.currentDate.year, widget.currentDate.month, widget.currentDate.day);
        if (widget.currentDate.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
          widget.enableTodayButton = false;
          widget.enableNextDayButton = false;
          widget.enablePreviousDayButton = true;
          widget.enableOldestDateButton = true;
        }
      });
    }
}
