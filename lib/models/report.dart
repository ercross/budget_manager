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

  ///typeDate holds only the year and month this report covers, 
  ///formatted like so, (dateRange.year).(dateRang.month).
  ///for reportType.yearly, a possible value = 2021.0, where 2021 = year and 0 indicates this report has no month attached to it
  ///for reportType.monthly, a possible value = 2021.3, where 3 is the month number, e.g DateTime.march
  ///for reportType.weekly, typeDate holds the year.monthWeek
  ///for reportType.daily, typeDate == 0;
  final double typeDate;

  ///if ReportType is ReportType.weekly, then dateNumber denotes the weekNumber this report covers.
  ///To get the year in which the week belongs, check typeDate which will contain year.monthWeek
  ///If dateNumber is 0, then budget is either ReportType.yearly or ReportType.monthly
  ///If ReportType is ReportType.daily, then dateNumber contains DateTime(year, month, day).milliSecondsSinceEpoch
  ///the date whose equivalent in milliSEcondsSinceEpoch is to obtained must be formatted as DateTime(year, month, day)
  final int dateNumber;

  Report({
    @required this.budget, 
    @required this.income, 
    @required this.habit,
    @required this.expense, 
    @required this.type, 
    @required this.dateNumber, 
    @required this.typeDate, 
  }) : id = DateTime.now().millisecondsSinceEpoch, netTotal = income - budget;

  @override
  List<Object> get props => [id, budget, income, expense, type, dateNumber, typeDate, habit];

  Report.fromMap(Map<String, dynamic> map) :
    id = map[ReportTable.columnId],
    dateNumber = map[ReportTable.columnDateNumber],
    typeDate = map[ReportTable.columnTypeDate],
    budget = map[ReportTable.columnBudget],
    income = map[ReportTable.columnIncome],
    expense = map[ReportTable.columnExpense],
    netTotal = map[ReportTable.columnNetTotal],
    habit = SpendingHabit.values[map[ReportTable.columnSpendingHabit]],
    type = ReportType.values[map[ReportTable.columnType]];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      ReportTable.columnDateNumber: dateNumber,
      ReportTable.columnTypeDate: typeDate,
      ReportTable.columnType: type.index, 
      ReportTable.columnBudget: budget,
      ReportTable.columnNetTotal: netTotal,
      ReportTable.columnExpense: expense,
      ReportTable.columnIncome: income,
      ReportTable.columnSpendingHabit: habit.index,
      ReportTable.columnId: id,
    };
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
    "\nid: $id \ndate number: $dateNumber \ntypeDate: $typeDate" +
    "\nbudget: $budget \nexpense: $expense \nincome: $income" + 
    "\nspending habit: ${habit.toString()} \nnet total: $netTotal";
  }
}