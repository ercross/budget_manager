import 'package:budget_manager/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../bloc/chart/chart_event.dart';
import '../bloc/chart/chart_bloc.dart';
import '../models/expense.dart';
import '../bloc/expense/expense_bloc.dart';
import './expense_card.dart';
import 'days_navigator.dart';

class ExpenseList extends StatefulWidget {

  ///use DaysNavigation.expenseListOnDisplay to assess this expenses
  final List<Expense> expenses;

  ExpenseList(this.expenses);

  @override
  _ExpenseList createState() => _ExpenseList();
}

class _ExpenseList extends State<ExpenseList> {

  String _currencySymbol;

  @override
  Widget build(BuildContext context) {

    return _buildExpenseList();
  }

  final Center noExpensesAdded = const Center(
    child: Text(
      "No Expenses Found",
      style: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(171, 39, 79, 0.4),
          fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildExpenseList() {
    
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {

        if (_currencySymbol == null) {
          _currencySymbol = Repository.repository.currencySymbol;
        }

        if (state is ENewCurrencySymbol){
          _currencySymbol = state.currencySymbol;
        }

        else if (state is ExpenseStateIncreased ) {
          widget.expenses.add(state.expense);
        }

        else if (state is ExpenseStateReduced && widget.expenses.isNotEmpty) {
          widget.expenses.removeWhere((expense) => expense.id == state.id);
        }

        else if (state is ExpenseStateFetched && state.expenses.isNotEmpty) {
          return ListView.builder(
          itemCount: state.expenses.length,
          itemBuilder: (buildContext, index) {
            return ExpenseCard(expense: state.expenses[index], 
                               deleteExpense:_deleteExpense,
                               currencySymbol: _currencySymbol,);
          });  
        } 
        else {
          return noExpensesAdded;
        }
        return ListView.builder(
          itemCount: widget.expenses.length,
          itemBuilder: (buildContext, index) {
            return ExpenseCard(expense: widget.expenses[index], 
                               deleteExpense:_deleteExpense,
                               currencySymbol: _currencySymbol,);
          });
      },
    );
  }

  void _deleteExpense (Expense expense) {
    setState(() {
      widget.expenses.remove(expense);
    });
    BlocProvider.of<ExpenseBloc>(context).add(DeleteExpense(expense.id));
    BlocProvider.of<ChartBloc>(context).add(AddOrRemoveExpenseFromChart(expense));
  }
}
