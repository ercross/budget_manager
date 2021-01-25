import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../repository/repository.dart';
import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Function (Expense expense) deleteExpense ;

  ExpenseCard({@required this.expense, @required this.deleteExpense});

  @override
  Widget build(BuildContext context) {
    
    final Container amount = Container(
      height: 100,
      width: 80,
      margin: EdgeInsets.only(left: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).primaryColor,  
      ),
      child: Center(
        child: Text(
          "${Repository.repository.currency}${expense.amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
    );

    final Text title = Text(
      expense.title,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
    );

    final Text date = Text(DateFormat('EEE MMM d, yyyy').format(expense.date),
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey));

    return Card(
      elevation: 10,
      shape: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor,
          style: BorderStyle.solid),
      shadowColor: Theme.of(context).primaryColor,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        enabled: true,
        leading: amount,
        title: title,
        subtitle: date,
        trailing: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.deepOrange,
            onPressed: () => deleteExpense(expense)),
      ),
    );
  }
}
