import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../vanilla_bloc/expense_bloc.dart';
import '../models/expense.dart';
import '../vanilla_bloc/expense_event.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final ExpenseBloc expenseBloc;

  ExpenseCard(this.expense, this.expenseBloc);

  @override
  Widget build(BuildContext context) {
    final CircleAvatar expenseAmountWidget = CircleAvatar(
      radius: 40,
      backgroundColor: Theme.of(context).primaryColor,
      child: Center(
        child: Text(
          expense.amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
    );

    final Text expenseTitleWidget = Text(
      expense.title,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
    );

    final Text expenseDateWidget = Text(DateFormat("EEE, dd-M-yyyy").format(expense.date),
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87));

    return Card(
      elevation: 4,
      shape: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor,
          style: BorderStyle.solid),
      shadowColor: Theme.of(context).primaryColor,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        enabled: true,
        leading: expenseAmountWidget,
        title: expenseTitleWidget,
        subtitle: expenseDateWidget,
        trailing: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.deepOrange,
            onPressed: deleteExpense),
      ),
    );
  }

  void deleteExpense() {
    expenseBloc.eventInput.add(DeleteExpense(this.expense));
  }
}
