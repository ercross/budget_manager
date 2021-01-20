import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../repository/db_tables.dart';

enum ReportType {
  daily,
  weekly,
  monthly,
  yearly,
}

enum SpendingHabit {
  frugal, 
  economic,
  splasher,
}

class Report extends Equatable{

  final int id;
  final double budget; //budget.amount associated with this report
  final SpendingHabit habit;
  final double netTotal;
  final double income; //income.amount associated with this report
  final double expense; //expense.amount associated with this report
  final ReportType type;

  ///date is the date for which this report was prepared. 
  ///For reports that spans across a date range, date = start date
  final DateTime date;

  ///typeDate is a concatenated form of the dateRange. It is formatted based on ReportType
  ///for reportType.yearly, a possible value = 2021.0, where 2021 = year and 0 indicates this report has no month attached to it
  ///for reportType.monthly, a possible value = 2021.3, where 3 is the month number, e.g DateTime.march
  ///for reportType.weekly, a possible value = 2021.31 where 1 is the week number
  ///This way, each report entry will be unique
  ///Regardless that the month is greater than 10, this method will still be effective since the field is only used to query
  final double typeDate;

  const Report({
    this.id,
    @required this.budget, 
    @required this.income, 
    @required this.habit,
    @required this.expense, 
    @required this.type, 
    @required this.date, 
    @required this.typeDate, 
  }) : netTotal = income - budget;

  @override
  List<Object> get props => [id, budget, income, expense, type, date, typeDate, habit];

  Report.fromMap(Map<String, dynamic> map) :
    id = map[ReportTable.columnId],
    date = DateTime.fromMillisecondsSinceEpoch(map[ReportTable.columnDate]),
    typeDate = map[ReportTable.columnTypeDate],
    budget = map[ReportTable.columnBudget],
    income = map[ReportTable.columnIncome],
    expense = map[ReportTable.columnExpense],
    netTotal = map[ReportTable.columnNetTotal],
    habit = SpendingHabit.values[map[ReportTable.columnSpendingHabit]],
    type = ReportType.values[map[ReportTable.columnType]];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      ReportTable.columnDate: date.millisecondsSinceEpoch,
      ReportTable.columnTypeDate: typeDate,
      ReportTable.columnType: type.index, 
      ReportTable.columnBudget: budget,
      ReportTable.columnNetTotal: netTotal,
      ReportTable.columnExpense: expense,
      ReportTable.columnIncome: income,
      ReportTable.columnSpendingHabit: habit.index,
    };
    if ( id != null) {
      map[BudgetTable.columnId] = id;
    }
    return map;
  }

  static List<Report> fromMaps(List<Map<String, dynamic>> maps) {
    final List<Report> reports = List<Report>();
    maps.forEach((map) => reports.add(Report.fromMap(map)));
    return reports;
  }

  static List<Map<String, dynamic>> toMaps (List<Report> reports) {
    final List<Map<String, dynamic>> maps = List<Map<String, dynamic>>();
    reports.forEach( (report) => maps.add(report.toMap()));
    return maps;
  }

  @override
  String toString() {
    return "report with type: ${type.toString()}" +
    "\n id: $id \n date: $date \n typeDate: $typeDate" +
    "\n Report: $budget \n expense: $expense \n income: $income" + 
    "\n spending habit: ${habit.toString()} \n net total: $netTotal";
  }
}