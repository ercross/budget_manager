import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackIt/cubit/middlenavbar_cubit.dart';

import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../bloc/chart/chart_event.dart';
import '../bloc/chart/chart_bloc.dart';
import '../models/expense.dart';
import '../bloc/expense/expense_bloc.dart';
import './expense_card.dart';
import 'middle_nav_bar.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList();

  @override
  _ExpenseList createState() => _ExpenseList();
}

class _ExpenseList extends State<ExpenseList> with WidgetsBindingObserver{

  String _currencySymbol = Repository.repository.currencySymbol;
  
  List<Expense> expenses;

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);  
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    Repository.repository.getAll(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [todaysDate.millisecondsSinceEpoch])
      .then((todaysExpenses){
        setState(() {
          expenses = todaysExpenses;          
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
    Repository.repository.getAll(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [todaysDate.millisecondsSinceEpoch])
      .then((todaysExpenses){expenses = todaysExpenses;});
    });
    }
  }

  final Widget _noExpensesAdded = const Center(
    child: Text(
      "No Expenses Added",
      style: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(171, 39, 79, 0.4),
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

            if (state is ENewCurrencySymbol) {
              _currencySymbol = state.currencySymbol;
              Repository.repository.setCurrencySymbol(state.currencySymbol);
              return _buildListView(expenses);
            }

            if (state is ExpenseStateIncreased) {
              final currentDate = DateTime(MiddleNavBarCubit.currentDate.year, 
                                    MiddleNavBarCubit.currentDate.month, MiddleNavBarCubit.currentDate.day);
              final expenseDate = DateTime(state.expense.date.year, state.expense.date.month, state.expense.date.day);

              if (currentDate.isAtSameMomentAs(expenseDate)) {
                expenses == null ? expenses = [state.expense] : expenses.add(state.expense);
                return _buildListView(expenses); 
              }
              else {
                expenses = state.expenses;
                final DateTime todaysDateF = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                BlocProvider.of<MiddleNavBarCubit>(context).emitNew(MiddleNavBar(
                  currentDate: state.expense.date,
                  enableOldestDateButton: Repository.repository.oldestDate.isBefore(expenseDate),
                  enablePreviousDayButton: expenseDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestDate),
                  enableNextDayButton: expenseDate.add(Duration(days: 1)).isBefore(todaysDateF),
                  enableTodayButton: expenseDate.isBefore(todaysDateF),));  
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
            currencySymbol: _currencySymbol,
          );
        });
  }

  void _deleteExpense(Expense expense) {
    BlocProvider.of<ExpenseBloc>(context).add(DeleteExpense(expense.id));
    BlocProvider.of<ChartBloc>(context)
        .add(AddOrRemoveExpenseFromChart(expense));
  }
}
