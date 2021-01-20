import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../screens/expenses_screen.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../bloc/chart/chart_bloc.dart' as chart;
import '../models/expense.dart';
import '../bloc/expense/expense_bloc.dart';
import './expense_card.dart';
import 'middle_nav_bar.dart';

class ExpenseTiles extends StatefulWidget {
  const ExpenseTiles();

  @override
  _ExpenseTiles createState() => _ExpenseTiles();
}

class _ExpenseTiles extends State<ExpenseTiles> with WidgetsBindingObserver{

  List<Expense> expenses = List<Expense>();

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    Repository.repository.fetch(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [todaysDate.millisecondsSinceEpoch]).then((maps){
        setState(() {
          expenses = Expense.fromMaps(maps);
          BlocProvider.of<MiddleNavBarCubit>(ExpensesPageBody.expensesScreenContext).emitInitial(MiddleNavBarOn.expensePage);          
        });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState (AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      setState ( () {
    Repository.repository.fetch(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [todaysDate.millisecondsSinceEpoch]).then((maps) => expenses = Expense.fromMaps(maps));
    });
    }
  }

  final Widget _noExpensesAdded = Center(
    child: Text(
      "No Expenses Added",
      style: TextStyle(
          fontSize: 20,
          color: Colors.green.withOpacity(0.5),
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is CurrentDate) {
              expenses = state.expenses;
              return _buildListView(expenses);
            }

            if (state is CurrencyChanged) {
              return _buildListView(expenses);
            }

            if (state is ExpenseStateIncreased) {
              final expenseDate = DateTime(state.expense.date.year, state.expense.date.month, state.expense.date.day);

              if (MiddleNavBarCubit.expensePageDateF.isAtSameMomentAs(expenseDate)) {

                //TODO: This is a fix for a bug encountered that causes income added to be readded again 
                //once a swipe is made off the page and back to the page. Find the problem, rather than this hack
                if (expenses.isNotEmpty) expenses.removeWhere((income) { return
                  income.amount == state.expense.amount
                  && income.date == state.expense.date
                  && income.title == state.expense.title;} );
                expenses.add(state.expense);
                return _buildListView(expenses); 
              }
              else {
                expenses = state.expenses;
                final DateTime todaysDateF = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                BlocProvider.of<MiddleNavBarCubit>(context).emitNew(
                  MiddleNavBar(
                    oldestDate: Repository.repository.oldestExpenseDate,
                    currentDate: state.expense.date,
                    enableOldestDateButton: Repository.repository.oldestExpenseDate.isBefore(expenseDate),
                    enablePreviousDayButton: expenseDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestExpenseDate),
                    enableNextDayButton: expenseDate.add(Duration(days: 1)).isBefore(todaysDateF),
                    enableTodayButton: expenseDate.isBefore(todaysDateF),),
                  MiddleNavBarOn.expensePage);  
                  return _buildListView(expenses);
              }
            }

            if (state is RemoveExpense) {
              expenses.removeWhere((expense) => expense.id == state.id);
              return _buildListView(expenses);
            }
            return _buildListView(expenses);
          },
        );
  }

  Widget _buildListView(List<Expense> expenses) {
    if (expenses == null || expenses.isEmpty) {
      return _noExpensesAdded;
    }
    
    return ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (buildContext, index) {
          return ExpenseCard(
            expense: expenses[index],
            deleteExpense: _deleteExpense,
          );
        });
  }

  void _deleteExpense(Expense expense) {
    BlocProvider.of<ExpenseBloc>(context).add(DeleteExpense(expense.id));
    BlocProvider.of<chart.ChartBloc>(context)
        .add(chart.ModifyChart(chart.ChartName.expense, expense));
  }
}
