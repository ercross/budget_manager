import 'dart:async';

import 'package:sqflite/sqflite.dart';

class ExpenseTable {
  static const String tableName = "expenseTable";
  static const String columnId = "id";
  static const String columnDate = "date";
  static const String columnAmount = "amount";
  static const String columnTitle = "title";
  static const String columnMonthAdded = "monthAdded";
  static const String columnYearAdded = "yearAdded";

  static FutureOr<void> create (Database database, int version) async {
    await database.execute ('CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, ' + 
      '$columnTitle TEXT, $columnAmount REAL, $columnDate INTEGER, ' + 
      '$columnMonthAdded INTEGER, $columnYearAdded INTEGER)');
  }
}

class IncomeTable {
  static const String tableName = "incomeTable";
  static const String columnId = "id";
  static const String columnDate = "date";
  static const String columnAmount = "amount";
  static const String columnSource = "source";
  static const String columnMonth = "month";
  static const String columnYear = "year";

  static FutureOr<void> create (Database database, int version) async {
    await database.execute ('CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, ' + 
      '$columnSource TEXT, $columnAmount REAL, $columnDate INTEGER, $columnMonth INTEGER ' +
       '$columnMonth INTEGER, $columnYear INTEGER)');
  }
}

class BudgetTable {
  static const String tableName = "budgetTable";
  static const String columnId = "id";
  static const String columnDate = "date";
  static const String columnTypeDate = "typeDate";
  static const String columnAmount = "amount";
  static const String columnType = "type";

  static FutureOr<void> create (Database database, int version) async {
    await database.execute ('CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, ' + 
      '$columnDate INTEGER, $columnTypeDate REAL, $columnAmount REAL, $columnType INTEGER)');
  }
}

class ReportTable {
  static const String tableName = "reportTable";
  static const String columnId = "id";
  static const String columnDate = "date";
  static const String columnTypeDate = "typeDate";
  static const String columnBudget = "budget";
  static const String columnSpendingHabit = "spendingHabit";
  static const String columnExpense = "expense";
  static const String columnType = "reportType";
  static const String columnIncome = "income";
  static const String columnNetTotal = "netTotal";

  static FutureOr<void> create (Database database, int version) async {
    await database.execute ('CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, ' + 
      '$columnDate INTEGER, $columnTypeDate REAL, $columnBudget REAL, ' + 
      '$columnSpendingHabit INTEGER, $columnExpense REAL, $columnType INTEGER, $columnIncome REAL, $columnNetTotal REAL)');
  }
  }