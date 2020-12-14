import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../repository/database_provider.dart';

class Expense extends Equatable{
  final int id;
  final String title;
  final double amount;
  final DateTime date;

  const Expense ({
    this.id,
    @required this.title,
    @required this.amount,
    @required this.date
  }) ;

  @override
  List<Object> get props => [id, title, amount, date];

  Expense.fromMap(Map<String, dynamic> map) :
    id = map[ExpenseTable.columnId],
    title = map[ExpenseTable.columnTitle],
    amount = map[ExpenseTable.columnAmount],
    date = DateTime.fromMillisecondsSinceEpoch((map[ExpenseTable.columnDate]));

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      ExpenseTable.columnAmount: amount,
      ExpenseTable.columnTitle: title,
      ExpenseTable.columnDate: DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
    };
    if ( id != null) {
      map[ExpenseTable.columnId] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "id: $id \n title: $title \n amount: $amount \n date: ${date.toString()}";
  }
}