import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../repository/repository.dart';
import '../models/week.dart';
import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard(this.report);

  Color _decideBoxColor(BuildContext ctx) {
    Color color;
    switch (report.habit) {
      case SpendingHabit.frugal:
        color = Theme.of(ctx).accentColor;
        break;
      case SpendingHabit.economic:
        color = Theme.of(ctx).primaryColor;
        break;
      case SpendingHabit.splasher:
        color = Colors.deepOrange;
        break;
    }
    return color;
  }

  String _writeDate() {
    final DateFormat f = DateFormat('EEE MMM d, yyyy');
    String date;

    switch (report.type) {
      case ReportType.daily:
        date = "${f.format(DateTime.fromMillisecondsSinceEpoch(report.dateNumber))}";
        break;
      
      case ReportType.weekly:
        Weeks weeks = Weeks(inYear: Year(DateTime.now().year));
        Week week = weeks.getWeekByNumber(report.dateNumber);
        final String dateRange = "${f.format(week.starts)} to \n${f.format(week.ends)}";
        date = "week ${report.dateNumber}\n$dateRange";
        break;

      case ReportType.monthly:
        final String year = report.typeDate.toString().split(".")[0];
        final int monthNum = int.parse(report.typeDate.toString().split(".")[1]);
        final String month = DateFormat('MMMM').format(DateTime(2000, monthNum));
        date = "\n$month $year";
        break;

      case ReportType.yearly:
        date = "\n${report.typeDate.toString().split(".")[0]}";
        break;
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {

    Color boxColor = _decideBoxColor(context);

    final Widget leading = Container(
      decoration: BoxDecoration(
        border: Border.all(color: boxColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: boxColor,
      ),
      padding: EdgeInsets.all(5),
      height: 80,
      width: 100,
      child: Center(
        child: Text("${Repository.repository.currency}${report.netTotal}", style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 17,
          color: Colors.white, 
          fontFamily: "Roboto"
          ),),
      )
    );

    final Widget trailing = Text("${report.habit.toString().split(".")[1]} spender  ", style: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 15,
        color: boxColor)
    );

    return Card(
      elevation: 10,
      shape: Border.all(
          width: 1,
          color: boxColor,
          style: BorderStyle.solid),
      shadowColor: boxColor,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        enabled: true,
        leading: leading,
        onTap: () => showDetails(context),
        trailing: trailing,
      )
    );
  }

  void showDetails(BuildContext context) {
    final String date = _writeDate();
    Alert(
      context: context,
      title: "Report for:",
      desc: date,
      style: AlertStyle(
        titleStyle: TextStyle(fontFamily: "Pacifico", fontSize: 12, color: Colors.grey),
        descStyle: TextStyle(fontFamily: "OleoScript", fontSize: 14, color: _decideBoxColor(context))),
      closeIcon: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
      content: Column(
        children: [
          _makeDetailsText(context, "Budget: ", report.budget.toString() ),
          _makeDetailsText(context, "Total Expenses: ", report.expense.toString()),
          _makeDetailsText(context, "Total Income: ", report.income.toString()),
          _makeDetailsText(context, "Net Total: ", report.netTotal.toString()),
        ],
      ),
      buttons: [DialogButton(
        child: Text(report.habit.toString().split(".")[1], style: TextStyle(fontSize: 18, color: Colors.white)),
        onPressed: ()=> Navigator.of(context).pop(),
        color: Theme.of(context).primaryColor,
      )]
    ).show();
  }

  Widget _makeDetailsText(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
        Text("${Repository.repository.currency}$value", style: TextStyle(
          color: Colors.black,
          fontSize: 15,
        )),
      ],
    );
  }
}