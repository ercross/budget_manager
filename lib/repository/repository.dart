import 'package:budget_manager/models/chart_data_date_range.dart';
import 'package:budget_manager/repository/preferences.dart';
import 'package:flutter/material.dart';

import '../repository/database_provider.dart';
import '../models/expense.dart';

///The app would be using more than one persistence option, 
///This repository is provided as an abstraction to these persistence options
class Repository {

  Repository._();

  static final Repository repository = Repository._();
  final DatabaseProvider db = DatabaseProvider.databaseProvider;
  final Preferences prefs = Preferences.prefs;

  Future<void> insert (String tableName, Expense expense) async {
    await db.insert(tableName, expense);
  }

  ///passing in null values for where and targetValues deletes the whole table specified by tableName
  Future<void> delete ({@required String tableName, String where, List<dynamic> targetValues}) async {
    await db.delete(tableName: tableName, where: where, targetValues: targetValues);
  }

  Future<void> update (String tableName, int id, Expense expense) async {
    await db.update(tableName, id, expense);
  }

  Future<List<Expense>> getAll (String tableName, {String where, List<dynamic> whereArgs}) async {
    return await db.getAll(tableName, where: where, whereArgs: whereArgs);
  }

  Future<List<List<Expense>>> batchGet (String tableName, String where, List<DateTime> whereArgs) async {
    return await db.batchGet(tableName, where, whereArgs);
  }

  Future<ChartDataDateRange> getChartDataDateRange() async {
    final dateRange = await prefs.fetchChartDataDateRange();
    if (dateRange == null) {
      return prefs.chartDataDateRange;
    }
    return dateRange;
  }

  Future<void> setChartDataDateRange(ChartDataDateRange chartDataDateRange) async {
    await prefs.setChartDataDateRange(chartDataDateRange);
  }
}