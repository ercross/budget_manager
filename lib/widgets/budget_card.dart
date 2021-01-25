import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../repository/repository.dart';
import '../models/week.dart';
import '../models/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final Function (Budget budget) delete ;

  BudgetCard({@required this.budget, @required this.delete});

  String weekNumber = "";

  Widget _writeSubtitle () {
    String subtitle;
    final DateFormat f = DateFormat('EEE MMM d, yyyy');
    switch (budget.type) {

      case BudgetType.weekly:
        Weeks weeks = Weeks(inYear: Year(DateTime.now().year));
        Week week = weeks.getWeekByNumber(budget.dateNumber);
        weekNumber = "week ${budget.dateNumber}";
        subtitle = "starts: ${f.format(week.starts)}\nends:   ${f.format(week.ends)}";
        break;

      case BudgetType.daily: 
        subtitle = "${f.format(DateTime.fromMillisecondsSinceEpoch(budget.dateNumber))}";
        break;

      case BudgetType.monthly:
        final String year = budget.typeDate.toString().split(".")[0];
        final int monthNum = int.parse(budget.typeDate.toString().split(".")[1]);
        final String month = DateFormat('MMMM').format(DateTime(2000, monthNum));
        subtitle = "$month $year";
        break;

      case BudgetType.yearly:
        subtitle = budget.typeDate.toString().split(".")[0];
        break;
    }
    return Text(subtitle, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold));
  }

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

    final Text title = Text("budget for: $weekNumber" , style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
    );

    return Card(
      elevation: 10,
      shape: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor,
          style: BorderStyle.solid),
      shadowColor: Theme.of(context).primaryColor,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        enabled: true,
        leading: amount,
        title: title,
        isThreeLine: budget.type == BudgetType.weekly,
        subtitle: _writeSubtitle(),
        trailing: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.deepOrange,
            onPressed: () => delete(budget)),
      ),
    );
  }
}
