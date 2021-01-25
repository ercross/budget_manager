import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../repository/db_tables.dart';

enum BudgetType {
  daily, 
  weekly, ///a week is Monday to Sunday
  monthly,
  yearly,
}

class Budget extends Equatable {

  final int id;
  final double amount;
  final BudgetType type;

  ///typeDate holds only the year and month this budget date range covers, 
  ///formatted like so, (dateRange.year).(dateRang.month).
  ///for BudgetType.yearly, a possible value = 2021.0, 
  ///where 2021 = year and 0 indicates this budget has no month attached to it.
  ///for BudgetType.monthly, a possible value = 2021.3, where 3 is the month number, e.g DateTime.march
  ///for BudgetType.weekly and BudgetType.daily, check this.dateNumber,
  final double typeDate;

  ///weekNumber denotes the weekNumber this budget covers
  ///If weekNumber is 0, then budget is either BudgetType.yearly or BudgetType.monthly
  ///If BudgetType is BudgetType.daily, then weekNumber contains date.milliSecondsSinceEpoch
  final int dateNumber;


  Budget({
    @required this.dateNumber,
    @required this.amount, 
    @required this.type,  
    @required this.typeDate}) : id = DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object> get props => [id, amount, type, dateNumber, typeDate];

  Budget.fromMap(Map<String, dynamic> map) :
    id = map[BudgetTable.columnId],
    dateNumber = (map[BudgetTable.columnDateNumber]),
    typeDate = map[BudgetTable.columnTypeDate],
    amount = map[BudgetTable.columnAmount],
    type = BudgetType.values[map[BudgetTable.columnType]];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      BudgetTable.columnAmount: amount,
      BudgetTable.columnDateNumber: dateNumber,
      BudgetTable.columnTypeDate: typeDate,
      BudgetTable.columnType: type.index,
      BudgetTable.columnId: id,
    };
    return map;
  }


  static List<Budget> fromMaps(List<Map<String, dynamic>> maps) {
    final List<Budget> budgets = List<Budget>();
    maps.forEach((map) => budgets.add(Budget.fromMap(map)));
    return budgets;
  }

  static List<Map<String, dynamic>> toMaps (List<Budget> budgets) {
    final List<Map<String, dynamic>> maps = List<Map<String, dynamic>>();
    budgets.forEach( (budget) => maps.add(budget.toMap()));
    return maps;
  }

  @override
  String toString() {
    return "id: $id \n date number: $dateNumber \n typeDate: $typeDate \n amount: $amount \n type: ${type.toString()}";
  }

}