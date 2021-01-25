import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import '../repository/db_tables.dart';

class Expense extends Equatable{
  final int id;
  final String title;
  final double amount;
  final DateTime date;

  ///yearAdded is this expense was added to trackit
  final int yearAdded;

  Expense ({
    @required this.title,
    @required this.amount,
    @required this.date
  }) : this.id = DateTime.now().millisecondsSinceEpoch, yearAdded = date.year;

  @override
  List<Object> get props => [id, title, amount, date, yearAdded];

  Expense.fromMap(Map<String, dynamic> map) :
    id = map[ExpenseTable.columnId],
    title = map[ExpenseTable.columnTitle],
    amount = map[ExpenseTable.columnAmount],
    date = DateTime.fromMillisecondsSinceEpoch(map[ExpenseTable.columnDate]),
    yearAdded = map[ExpenseTable.columnYearAdded];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      ExpenseTable.columnAmount: amount,
      ExpenseTable.columnTitle: title,
      ExpenseTable.columnDate: date.millisecondsSinceEpoch,
      ExpenseTable.columnYearAdded: yearAdded,
      ExpenseTable.columnId: id,
    };
    return map;
  }

  static List<Expense> fromMaps(List<Map<String, dynamic>> maps) {
    final List<Expense> expenses = List<Expense>();
    maps.forEach((map) => expenses.add(Expense.fromMap(map)));
    return expenses;
  }

  static List<Map<String, dynamic>> toMaps (List<Expense> expenses) {
    final List<Map<String, dynamic>> maps = List<Map<String, dynamic>>();
    expenses.forEach( (expense) => maps.add(expense.toMap()));
    return maps;
  }

  @override
  String toString() {
    return "id: $id \n title: $title \n amount: $amount \n date: ${date.toString()}";
  }
}