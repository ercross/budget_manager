import 'package:budget_manager/repository/database_provider.dart';
import 'package:budget_manager/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../bloc/expense_bloc.dart';
import './expense_card.dart';

class ExpenseList extends StatefulWidget {

  List<Expense> expenses = List<Expense>();

  ExpenseList();

  @override
  _ExpenseList createState() => _ExpenseList();
}

class _ExpenseList extends State<ExpenseList> {

  @override
  @override
  void initState() { 
    super.initState();
    DatabaseProvider.databaseProvider.getAll(ExpenseTable.tableName)
      .then((expenses) {
        BlocProvider.of<ExpenseBloc>(context).add(FetchExpenses(expenses));
        widget.expenses = expenses;
        });
  }

  @override
  Widget build(BuildContext context) {
    print("building new ExpenseList");
    return buildExpenseList();  
  }

  final Center noExpensesAdded = const Center(
    child: Text(
      "No Expenses Added Yet",
      style: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(171, 39, 79, 0.4),
          fontWeight: FontWeight.bold),
    ),
  );

  Widget buildExpenseList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {

        if (state is ExpenseStateLoaded ) {
          widget.expenses.add(state.expense);
          return new ListView.builder(
          itemCount: widget.expenses.length,
          itemBuilder: (buildContext, index) {
            return ExpenseCard(widget.expenses[index], _deleteExpense);
          }
          );
        }

        if (state is ExpenseStateReduced && widget.expenses.isNotEmpty) {
          widget.expenses.removeWhere((expense) => expense.id == state.id);
          return new ListView.builder(
          itemCount: widget.expenses.length,
          itemBuilder: (buildContext, index) {
            return ExpenseCard(widget.expenses[index], _deleteExpense);
          });
        }

        if (state is ExpenseStateFetched && state.expenses.isNotEmpty) {
          return new ListView.builder(
          itemCount: widget.expenses.length,
          itemBuilder: (buildContext, index) {
            return ExpenseCard(widget.expenses[index], _deleteExpense);
          });
        } else return noExpensesAdded;
      },
    );
  }

  void _deleteExpense (Expense expense) {
    setState(() {
      widget.expenses.remove(expense);
    });
    BlocProvider.of<ExpenseBloc>(context).add(DeleteExpense(expense.id));
    DatabaseProvider.databaseProvider.delete(tableName: ExpenseTable.tableName, where: "id=?", targetValues: [expense.id]);
  }
}
