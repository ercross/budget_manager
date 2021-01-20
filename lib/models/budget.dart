import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trackIt/repository/db_tables.dart';

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

  ///date is the date this budget was added. It is the date displayed on BudgetCard
  final DateTime date;

  ///typeDate is a concatenated form of the dateRange. It is formatted based on BudgetType
  ///for BudgetType.yearly, a possible value = 2021.0, where 2021 = year and 0 indicates this budget has no month attached to it
  ///for BudgetType.monthly, a possible value = 2021.3, where 3 is the month number, e.g DateTime.march
  ///for BudgetType.weekly, a possible value = 2021.31 where 1 is the week number
  ///This way, each budget entry will be unique
  ///Regardless that the month is greater than 10, this method will still be effective since the field is only used to query
  final double typeDate;

  Budget({
    this.id, 
    @required this.amount, 
    @required this.type, 
    @required this.date, 
    @required this.typeDate});

  @override
  List<Object> get props => [id, amount, type, date, typeDate];

  Budget.fromMap(Map<String, dynamic> map) :
    id = map[BudgetTable.columnId],
    date = DateTime.fromMillisecondsSinceEpoch(map[BudgetTable.columnDate]),
    typeDate = map[BudgetTable.columnTypeDate],
    amount = map[BudgetTable.columnAmount],
    type = BudgetType.values[map[BudgetTable.columnType]];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      BudgetTable.columnAmount: amount,
      BudgetTable.columnDate: date.millisecondsSinceEpoch,
      BudgetTable.columnTypeDate: typeDate,
      BudgetTable.columnType: type.index,
    };
    if ( id != null) {
      map[BudgetTable.columnId] = id;
    }
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
    return "id: $id \n date: $date \n typeDate: $typeDate \n amount: $amount \n type: ${type.toString()}";
  }

}