import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../providers/current_page_index.dart';
import '../bloc/expense/expense_bloc.dart';

class MiddleNavBar extends StatelessWidget {
  final bool enableOldestDateButton;
  final bool enablePreviousDayButton;
  final bool enableNextDayButton;
  final bool enableTodayButton;
  final DateTime currentDate;

  //This implementation allows multiple instances of MiddleNavBar to be used in the app
  ///oldestDate must be set on every NewMiddleNavBar sent out from MiddleNavBarCubit
  ///for MiddleNavBarInitial, it is set inside the BlocBuilder
  DateTime oldestDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  MiddleNavBar({
    @required this.enableOldestDateButton,
    @required this.enablePreviousDayButton,
    @required this.enableNextDayButton,
    @required this.enableTodayButton,
    @required this.currentDate,
    this.oldestDate
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
                onTap: () => _onOldestDateButtonPressed(ctx, pageIndex)),
            _buildNavIcon(
                ctx: ctx,
                enableButton: enablePreviousDayButton,
                icon: Icons.arrow_left_outlined,
                onTap: () => _onPreviousButtonPressed(ctx, pageIndex)),
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
                onTap: () => _onNextButtonPressed(ctx, pageIndex)),
            _buildNavIcon(
                ctx: ctx,
                enableButton: enableTodayButton,
                icon: Icons.fast_forward_outlined,
                onTap: () => _onTodayButtonPressed(ctx, pageIndex)),
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

  void _onTodayButtonPressed(BuildContext ctx, CurrentPageIndex pageIndex) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(todaysDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enableNextDayButton: false,
        enableTodayButton: false,
        enablePreviousDayButton: todaysDate.subtract(Duration(days: 1)).isAfter(oldestDate),
        enableOldestDateButton: true,
        currentDate: DateTime.now(),),
      MiddleNavBarOn.values[pageIndex.value]
      );
  }

  void _onOldestDateButtonPressed(BuildContext ctx, CurrentPageIndex pageIndex) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(oldestDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
       enableOldestDateButton: false,
       enablePreviousDayButton: false,
       enableNextDayButton: todaysDate.subtract(Duration(days: 1)).isAfter(oldestDate),
       enableTodayButton: true,
       currentDate: oldestDate,),
      MiddleNavBarOn.values[pageIndex.value]);
  }

  void _onPreviousButtonPressed(BuildContext ctx, CurrentPageIndex pageIndex) {
    DateTime previousDayDate = currentDate.subtract(Duration(days: 1));
    previousDayDate = DateTime(previousDayDate.year, previousDayDate.month, previousDayDate.day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(previousDayDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(
      MiddleNavBar(
        enablePreviousDayButton: previousDayDate.subtract(Duration(days: 1)).isAfter(oldestDate) 
                              && previousDayDate.isAfter(oldestDate),
        enableTodayButton: true,
        enableOldestDateButton: true,
        enableNextDayButton: true,
        currentDate: previousDayDate,),
      MiddleNavBarOn.values[pageIndex.value]);
  }

  void _onNextButtonPressed(BuildContext ctx, CurrentPageIndex pageIndex) {
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
      MiddleNavBarOn.values[pageIndex.value]);
  }
}
