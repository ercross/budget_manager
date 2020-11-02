import 'package:flutter/material.dart';
import '../expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;

  ExpenseCard(this.expense);

  @override
  Widget build(BuildContext context) {
    return Card(
                  elevation: 5,
                  child: Row(
                    children: <Widget>[
                      Container
                      (
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10
                        ) ,
                        decoration: BoxDecoration(
                          border: Border.all(width: 3, color: Colors.purple),
                        ),
                        padding: EdgeInsets.all(7),
                        child: Text(
                          expense.amount.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple
                          ),),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(expense.title, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,

                            ),
                          ),
                          Text(expense.date.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ))
                        ]
                      )
                    ],
                  ),);
  }
}