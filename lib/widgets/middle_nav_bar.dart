import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trackIt/bloc/income/income_bloc.dart';
import 'package:trackIt/repository/repository.dart';

import '../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../providers/current_page_index.dart';
import '../bloc/expense/expense_bloc.dart';

class MiddleNavBar extends StatelessWidget {
  final bool enableOldestDateButton;
  final bool enablePreviousDayButton;
  final bool enableNextDayButton;
  final bool enableTodayButton;
  final DateTime currentDate;

  MiddleNavBar({
    @required this.enableOldestDateButton,
    @required this.enablePreviousDayButton,
    @required this.enableNextDayButton,
    @required this.enableTodayButton,
    @required this.currentDate,
  });

  @override
  Widget build(BuildContext ctx) {
    final pageIndex = Provider.of<CurrentPageIndex>(ctx, listen: false);
    DateFormat dateFormat;

    //pageIndex.value == 0 is the expensePage. pageIndex.value == 1 is the incomePage
    pageIndex.value == 0 ? dateFormat = DateFormat('EEE MMM d, yyyy') : dateFormat = DateFormat('MMMM yyyy');
    return Row(
          children: [
            _buildNavIcon(
                ctx: ctx,
                enableButton: enableOldestDateButton,
                icon: Icons.fast_rewind_outlined,
                onTap: () => pageIndex.value == 0 
                              ? _onOldestDateButtonPressedEP(ctx) 
                              : _onOldestDateButtonPressedIP(ctx),),
            _buildNavIcon(
                ctx: ctx,
                enableButton: enablePreviousDayButton,
                icon: Icons.arrow_left_outlined,
                onTap: () => pageIndex.value == 0 
                              ? _onPreviousButtonPressedEP(ctx) 
                              : _onPreviousButtonPressedIP(ctx),),

            Expanded(
                child: FittedBox(
                    child: Text(dateFormat.format(currentDate),
              style: TextStyle(
                  color: Theme.of(ctx).accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ))),

            _buildNavIcon(
                ctx: ctx,
                enableButton: enableNextDayButton,
                icon: Icons.arrow_right_outlined,
                onTap: () => pageIndex.value == 0  
                              ? _onNextButtonPressedEP(ctx) 
                              : _onNextButtonPressedIP(ctx) ),

            _buildNavIcon(
                ctx: ctx,
                enableButton: enableTodayButton,
                icon: Icons.fast_forward_outlined,
                onTap: () => pageIndex.value == 0  
                              ? _onTodayButtonPressedEP(ctx) 
                              : _onTodayButtonPressedIP(ctx)),
          ],
    );
  }

  Widget _buildNavIcon(
      {@required bool enableButton,
      @required Function onTap,
      @required IconData icon,
      @required BuildContext ctx,
      }) {
    if (enableButton) {
      return GestureDetector(
        child: Icon(
          icon,
          size: 50,
          color: Theme.of(ctx).primaryColor
        ),
        onTap: onTap,
      );
    }
    return Icon(
      icon,
      size: 50,
      color: Colors.grey,
    );
  }

  /*The suffixes EP and IP means Expense page and Income page respectively. Used to avoid longer names*/

  void _onTodayButtonPressedEP(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(todaysDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableNextDayButton: false,
        enableTodayButton: false,
        enablePreviousDayButton: todaysDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestExpenseDate),
        enableOldestDateButton: true,
        currentDate: DateTime.now(),),
      MiddleNavBarOn.expensePage
      );
  }

  void _onTodayButtonPressedIP(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month);
    DateTime monthAfterOldestIncomeMonth;
    if (Repository.repository.oldestIncomeDate.month == 12) {
      monthAfterOldestIncomeMonth = DateTime(Repository.repository.oldestIncomeDate.year-1, 1);
    }
    else monthAfterOldestIncomeMonth = DateTime(Repository.repository.oldestIncomeDate.year, Repository.repository.oldestIncomeDate.month + 1);

    BlocProvider.of<IncomeBloc>(ctx).add(FetchIncomesFor(todaysDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableNextDayButton: false,
        enableTodayButton: false,
        enablePreviousDayButton: monthAfterOldestIncomeMonth.isBefore(todaysDate) ,
        enableOldestDateButton: true,
        currentDate: todaysDate,
      ),
      MiddleNavBarOn.incomePage,
      );
  }

  void _onOldestDateButtonPressedEP(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(Repository.repository.oldestExpenseDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
       enableOldestDateButton: false,
       enablePreviousDayButton: false,
       enableNextDayButton: todaysDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestExpenseDate),
       enableTodayButton: true,
       currentDate: Repository.repository.oldestExpenseDate),
      MiddleNavBarOn.expensePage);
  }

  void _onOldestDateButtonPressedIP (BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month);

    DateTime monthAfterOldestIncomeMonth;
    if (Repository.repository.oldestIncomeDate.month == 12) {
      monthAfterOldestIncomeMonth = DateTime(Repository.repository.oldestIncomeDate.year-1, 1);
    }
    else monthAfterOldestIncomeMonth = DateTime(Repository.repository.oldestIncomeDate.year, Repository.repository.oldestIncomeDate.month + 1);

    BlocProvider.of<IncomeBloc>(ctx).add(FetchIncomesFor(Repository.repository.oldestIncomeDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableOldestDateButton: false,
        enablePreviousDayButton: false,
        enableTodayButton: true,
        enableNextDayButton: monthAfterOldestIncomeMonth.isBefore(todaysDate),
        currentDate: Repository.repository.oldestIncomeDate,
      ),
      MiddleNavBarOn.incomePage
    );
  }

  void _onPreviousButtonPressedEP(BuildContext ctx) {
    DateTime previousDayDate = currentDate.subtract(Duration(days: 1));
    previousDayDate = DateTime(previousDayDate.year, previousDayDate.month, previousDayDate.day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(previousDayDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enablePreviousDayButton: previousDayDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestExpenseDate) 
                              && previousDayDate.isAfter(Repository.repository.oldestExpenseDate),
        enableTodayButton: true,
        enableOldestDateButton: true,
        enableNextDayButton: true,
        currentDate: previousDayDate,),
      MiddleNavBarOn.expensePage);
  }

  void _onPreviousButtonPressedIP(BuildContext ctx) {
    DateTime newCurrentMonth;
    if (currentDate.month == 1) newCurrentMonth = DateTime(currentDate.year-1, 12);
    else newCurrentMonth = DateTime(currentDate.year, currentDate.month-1);

    DateTime monthAfterOldestIncomeMonth;
    if (Repository.repository.oldestIncomeDate.month == 12) {
      monthAfterOldestIncomeMonth = DateTime(Repository.repository.oldestIncomeDate.year-1, 1);
    }
    else monthAfterOldestIncomeMonth = DateTime(Repository.repository.oldestIncomeDate.year, Repository.repository.oldestIncomeDate.month + 1);

    BlocProvider.of<IncomeBloc>(ctx).add(FetchIncomesFor(newCurrentMonth));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableOldestDateButton: true,
        enableTodayButton: true,
        enableNextDayButton: true,
        enablePreviousDayButton: monthAfterOldestIncomeMonth.isBefore(newCurrentMonth), //Repository.repository.oldestIncomeDate.month <
        currentDate: newCurrentMonth,
      ),
      MiddleNavBarOn.incomePage
    );
  }

  void _onNextButtonPressedEP(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime currentDateF = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final DateTime nextDayDate = currentDateF.add(Duration(days: 1));
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(nextDayDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableOldestDateButton: true,
        enableTodayButton: true,
        enablePreviousDayButton: true,
        enableNextDayButton: nextDayDate.add(Duration(days: 1)).isBefore(todaysDate) && nextDayDate.isBefore(todaysDate),
        currentDate: nextDayDate,),
      MiddleNavBarOn.expensePage);
  }

  void _onNextButtonPressedIP(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month);
    DateTime newCurrentMonth;
    if (currentDate.month == 12) newCurrentMonth = DateTime(currentDate.year+1, 1);
    else newCurrentMonth = DateTime(currentDate.year, currentDate.month+1);

    BlocProvider.of<IncomeBloc>(ctx).add(FetchIncomesFor(newCurrentMonth));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableOldestDateButton: true,
        enableTodayButton: true,
        enablePreviousDayButton: true,
        enableNextDayButton: DateTime(newCurrentMonth.year, newCurrentMonth.month+1).isBefore(todaysDate),
        currentDate: newCurrentMonth,
      ), 
      MiddleNavBarOn.incomePage
    );
  }
}
