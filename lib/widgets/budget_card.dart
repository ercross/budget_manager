import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trackIt/repository/repository.dart';

import '../models/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final Function (Budget budget) delete ;

  BudgetCard({@required this.budget, @required this.delete});

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
          "${Repository.repository.currency}${budget.amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
    );

    final List<String> typeText = ["Day", "Week", "Month"];
    final Text title = Text(
      typeText[budget.type.index],
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
    );

    final String startDate = DateFormat('EEE MMM d, yyyy').format(budget.startDate);
    final String endDate = DateFormat('EEE MMM d, yyyy').format(budget.endDate);
    final String dateText = budget.startDate.isAtSameMomentAs(budget.endDate) ? startDate : "$startDate - $endDate";

    final Text date = Text(dateText,
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87));

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
            onPressed: () => delete(budget)),
      ),
    );
  }
}
