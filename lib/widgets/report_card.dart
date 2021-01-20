import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:trackIt/repository/repository.dart';

import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard(this.report);

  @override
  Widget build(BuildContext context) {

    final List<String> spendingHabit = ["frugal", "economic", "splasher"];

    final Widget leading = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(1)),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        gradient: RadialGradient(
          colors: [Color.fromRGBO(196,202,206,1), Colors.grey],
          transform: GradientRotation(0.5)
        )
      ),
      padding: EdgeInsets.all(5),
      height: 80,
      width: 100,
      child: Text(spendingHabit[report.habit.index], style: TextStyle(
        fontStyle: FontStyle.italic, 
        fontSize: 16,
        color: Theme.of(context).primaryColor.withOpacity(1)
        ),)
    );

    final String startDate = DateFormat('EEE MMM d, yyyy').format(report.startDate);
    final String endDate = DateFormat('EEE MMM d, yyyy').format(report.endDate);
    final String dateText = report.startDate.isAtSameMomentAs(report.endDate) ? startDate : "$startDate - $endDate";

    final Widget date = Text(dateText,
        style: TextStyle(fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500, fontSize: 15, color: Theme.of(context).primaryColor));

    final Widget netAmount = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(1)),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        gradient: RadialGradient(
          colors: [Color.fromRGBO(196,202,206,1), Colors.grey],
          transform: GradientRotation(0.5)
        )
      ),
      padding: EdgeInsets.all(5),
      height: 80,
      width: 100,
      child: Text("${Repository.repository.currency}${report.netTotal.toStringAsFixed(0)}", style: TextStyle(
        fontStyle: FontStyle.italic, 
        fontSize: 16,
        color: Theme.of(context).primaryColor.withOpacity(1)
        ),)
    );

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
        leading: leading,
        onTap: () => showDetails(context, date),
        subtitle: date,
        trailing: netAmount,
      )
    );
  }

  void showDetails(BuildContext context, Widget date) {
    Alert(
      context: context,
      title: "Track report for \n $date",
      closeIcon: Icon(Icons.cancel, color: Theme.of(context).accentColor),
      content: Column(
        children: [
          _makeDetailsText(context, "Report type: ", report.type.toString()),
          _makeDetailsText(context, "Budget: ", report.budget.toStringAsFixed(0)),
          _makeDetailsText(context, "Total Expenses: ", report.expense.toStringAsFixed(0)),
          _makeDetailsText(context, "Total Income: ", report.income.toStringAsFixed(0)),
          _makeDetailsText(context, "Net Total: ", report.netTotal.toStringAsFixed(0)),
        ],
      ),
      buttons: [DialogButton(
        child: Text(report.habit.toString(), style: TextStyle(fontSize: 18)),
        onPressed: (){},
        color: Theme.of(context).accentColor,
      )]
    ).show();
  }

  Widget _makeDetailsText(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
        Text(value, style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 15,
        )),
      ],
    );
  }
}