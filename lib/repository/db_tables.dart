import 'dart:async';

import 'package:sqflite/sqflite.dart';

class ExpenseTable {
  static const String tableName = "expenseTable";
  static const String columnId = "id";
  static const String columnDate = "date";
  static const String columnAmount = "amount";
  static const String columnTitle = "title";

  static FutureOr<void> create (Database database, int version) async {
    await database.execute ('CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnAmount REAL, $columnDate INTEGER)');
  }
}