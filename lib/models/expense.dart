import '../repository/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

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
  });

  @override
  List<Object> get props => [id, title, amount, date];

  Expense.fromMap(Map<String, dynamic> map) :
    id = map[ExpenseTable.columnId],
    title = map[ExpenseTable.columnTitle],
    amount = map[ExpenseTable.columnAmount],
    date = DateTime.parse(map[ExpenseTable.columnDate]);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      ExpenseTable.columnAmount: amount,
      ExpenseTable.columnTitle: title,
      ExpenseTable.columnDate: date.toString(),
    };
    if ( id != null) {
      map[ExpenseTable.columnId] = id;
    }
    return map;
  }
}