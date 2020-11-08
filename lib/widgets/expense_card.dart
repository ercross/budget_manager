import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  ExpenseCard(this.expense);

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
          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
    );

    final Text expenseDateWidget = Text(expense.date.toString(),
        style: TextStyle(
            fontWeight: FontWeight.w300, fontSize: 14, color: Colors.black87));

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
            onPressed: () {}),
      ),
    );
  }
}
