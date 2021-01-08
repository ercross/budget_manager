import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trackIt/cubit/middlenavbar_cubit.dart';

import '../bloc/expense/expense_bloc.dart';
import '../repository/repository.dart';

class MiddleNavBar extends StatelessWidget {
  final bool enableOldestDateButton;
  final bool enablePreviousDayButton;
  final bool enableNextDayButton;
  final bool enableTodayButton;
  final DateTime currentDate;

  const MiddleNavBar({
    @required this.enableOldestDateButton,
    @required this.enablePreviousDayButton,
    @required this.enableNextDayButton,
    @required this.enableTodayButton,
    @required this.currentDate,
  });

  @override
  Widget build(BuildContext ctx) {
    return Row(
          children: [
            _buildNavIcon(
                ctx: ctx,
                enableButton: enableOldestDateButton,
                icon: Icons.fast_rewind_outlined,
                onTap: () => _onOldestDateButtonPressed(ctx)),
            _buildNavIcon(
                ctx: ctx,
                enableButton: enablePreviousDayButton,
                icon: Icons.arrow_left_outlined,
                onTap: () => _onPreviousButtonPressed(ctx)),
            Expanded(
                child: FittedBox(
                    child: Text(
              DateFormat('EEE MMM d, yyyy').format(currentDate),
              style: TextStyle(
                  color: Theme.of(ctx).accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ))),
            _buildNavIcon(
                ctx: ctx,
                enableButton: enableNextDayButton,
                icon: Icons.arrow_right_outlined,
                onTap: () => _onNextButtonPressed(ctx)),
            _buildNavIcon(
                ctx: ctx,
                enableButton: enableTodayButton,
                icon: Icons.fast_forward_outlined,
                onTap: () => _onTodayButtonPressed(ctx)),
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
          color: Theme.of(ctx).primaryColor,
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

  void _onTodayButtonPressed(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(todaysDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(MiddleNavBar(
      enableNextDayButton: false,
      enableTodayButton: false,
      enablePreviousDayButton: todaysDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestDate),
      enableOldestDateButton: true,
      currentDate: DateTime.now(),
    ));
  }

  void _onOldestDateButtonPressed(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(Repository.repository.oldestDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(MiddleNavBar(
       enableOldestDateButton: false,
       enablePreviousDayButton: false,
       enableNextDayButton: todaysDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestDate),
       enableTodayButton: true,
       currentDate: Repository.repository.oldestDate,   
    ));
    print("oldestButton pressed. OldestDate is ${Repository.repository.oldestDate}");
  }

  void _onPreviousButtonPressed(BuildContext ctx) {
    DateTime previousDayDate = currentDate.subtract(Duration(days: 1));
    previousDayDate = DateTime(previousDayDate.year, previousDayDate.month, previousDayDate.day);
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(previousDayDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(MiddleNavBar(
      enablePreviousDayButton: previousDayDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestDate) 
                              && previousDayDate.isAfter(Repository.repository.oldestDate),
      enableTodayButton: true,
      enableOldestDateButton: true,
      enableNextDayButton: true,
      currentDate: previousDayDate,
    ));
  }

  void _onNextButtonPressed(BuildContext ctx) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime currentDateF = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final DateTime nextDayDate = currentDateF.add(Duration(days: 1));
    BlocProvider.of<ExpenseBloc>(ctx).add(FetchExpensesFor(nextDayDate));
    BlocProvider.of<MiddleNavBarCubit>(ctx).emitNew(MiddleNavBar(
      enableOldestDateButton: true,
      enableTodayButton: true,
      enablePreviousDayButton: true,
      enableNextDayButton: nextDayDate.add(Duration(days: 1)).isBefore(todaysDate) && nextDayDate.isBefore(todaysDate),
      currentDate: nextDayDate,    
    ));
  }
}
