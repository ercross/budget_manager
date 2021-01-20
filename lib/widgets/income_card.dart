import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/income.dart';
import '../repository/repository.dart';

class IncomeCard extends StatelessWidget {
  final Income income;
  final Function (Income income) delete ;

  IncomeCard({@required this.income, @required this.delete});

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
          "${Repository.repository.currency}${income.amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
    );

    final Widget source = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("source: ", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
        Text(income.source, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black))
        ],
    );

    final Text date = Text(DateFormat('EEE MMM d, yyyy').format(income.date),
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87));

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
        title: source,
        subtitle: date,
        trailing: IconButton(
            icon: Icon(Icons.delete),
            color: Colors.deepOrange,
            onPressed: () => delete(income)),
      ),
    );
  }
}
