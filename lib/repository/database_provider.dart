import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/expense.dart';

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


class DatabaseProvider {
  static const String _databaseName = "expenses.db";
  static const int _databaseVersion = 1;

  DatabaseProvider._();

  static final DatabaseProvider databaseProvider = DatabaseProvider._();

  static Database _databaseDriver;

  Future<Database> _getDatabaseDriver () async {
    if (_databaseDriver != null) {
      return _databaseDriver;
    }
    return _databaseDriver = await _initializeDatabase();
  }

  Future<Database> _initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, _databaseName),
      onCreate: (Database database, int version) => ExpenseTable.create(database, version),
      version: _databaseVersion);
  }

  Future<void> insert (String tableName, Expense expense) async {
    final Database db = await _getDatabaseDriver();
    await db.insert(tableName, expense.toMap());
  }

  ///Target rows are specified through where and whereArgs.
  ///@param->where should be formatted like this: "targetColumn=?" and the number of question marks should tally with the number of arguments in @List.targetValues
  ///where: "id=?", whereArgs: [id]
  ///@param->targetValues specifies the data to find in the targetColumn. Any row on which any of the targetValues is found will be deleted
  Future<void> delete ({@required String tableName, String where, List<dynamic> targetValues}) async {
    final Database db = await _getDatabaseDriver();
    await db.delete (tableName, where: where, whereArgs: targetValues);
  }

  Future<void> update (String tableName, int id, Expense expense) async {
    final Database db = await _getDatabaseDriver();
    await db.update (tableName, expense.toMap(), where: "id=?", whereArgs: [id]);
  }

  ///getAll fetches all rows of the database or fetches item specified through where and whereArgs
  ///if where and whereArgs are null, the whole table item is returned
  Future<List<Expense>> getAll (String tableName, {String where, List<dynamic> whereArgs}) async {
    final Database db = await _getDatabaseDriver();
    List<Map<String, dynamic>> maps;
    maps = await db.query(tableName, where: where, whereArgs: whereArgs);
    final List<Expense> expenses = List<Expense>();
    maps.forEach((map) { expenses.add(Expense.fromMap(map)); });
    return expenses;
  }

  ///whereArgs is a list of occurrence to find on each row
  ///where shoul be formatted like so where: "id=?" if the search is to be done by id 
  Future<List<List<Expense>>> batchGet (String tableName, String where, List<DateTime> whereArgs) async {
    final Database db = await _getDatabaseDriver();
    final Batch batch = db.batch();
    List<List<Expense>> expenses = List<List<Expense>>();
    List<Expense> dailyExpense = List<Expense>();
    for (int i=0; i<whereArgs.length; i++) {
      batch.query(tableName, where: where, whereArgs: [whereArgs[i].millisecondsSinceEpoch]);
    }
    final maps = (await batch.commit(noResult: false)).cast<List<Map<String, dynamic>>>();
    for(int i=0; i<maps.length; i++) {
      maps[i].forEach((map) { dailyExpense.add(Expense.fromMap(map)); });
      expenses.add(dailyExpense);
    }
    return expenses;
  }

  Future<void> close() async => await _databaseDriver.close();
}