import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../repository/db_tables.dart';

class Income extends Equatable {
  final int id;
  final String source;
  final double amount;
  final DateTime date;

  //these fields were added to ease generation of monthly and yearly reports
  final DateTime month; 
  final DateTime year;

  Income({
    this.id, 
    @required this.source, 
    @required this.amount, 
    @required this.date}) : month = DateTime(date.year, date.month), 
                            year = DateTime(date.year);

  @override
  List<Object> get props => [id, source, amount, date, month, year];

  Income.fromMap(Map<String, dynamic> map) :
    id = map[IncomeTable.columnId],
    source = map[IncomeTable.columnSource],
    amount = map[IncomeTable.columnAmount],
    date = DateTime.fromMillisecondsSinceEpoch(map[IncomeTable.columnDate]),
    month = DateTime.fromMicrosecondsSinceEpoch(map[IncomeTable.columnMonth]),
    year = DateTime.fromMillisecondsSinceEpoch(map[IncomeTable.columnYear]);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      IncomeTable.columnAmount: amount,
      IncomeTable.columnSource: source,
      IncomeTable.columnDate: date.millisecondsSinceEpoch,
      IncomeTable.columnMonth: month.millisecondsSinceEpoch,
      IncomeTable.columnYear: year.millisecondsSinceEpoch
    };
    if ( id != null) {
      map[IncomeTable.columnId] = id;
    }
    return map;
  }

  static List<Income> fromMaps(List<Map<String, dynamic>> maps) {
    final List<Income> incomes = List<Income>();
    maps.forEach((map) => incomes.add(Income.fromMap(map)));
    return incomes;
  }

  static List<Map<String, dynamic>> toMaps (List<Income> incomes) {
    final List<Map<String, dynamic>> maps = List<Map<String, dynamic>>();
    incomes.forEach( (income) => maps.add(income.toMap()));
    return maps;
  }

  @override
  String toString() {
    return "id: $id \n source: $source \n amount: $amount \n date: ${date.toString()}";
  }
}