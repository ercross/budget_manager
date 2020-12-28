import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'db_tables.dart';
import '../models/chart_data_date_range.dart';
import '../models/expense.dart';

part 'database_provider.dart';
part 'preferences.dart';

///The app would be using more than one persistence option, 
///This repository is provided as an abstraction to these persistence options
class Repository {

  Repository._();

  static final Repository repository = Repository._();
  final DatabaseProvider _db = DatabaseProvider.databaseProvider;
  final Preferences _sharedPrefs = Preferences.preferences;

  Future<void> insert (String tableName, Expense expense) async {
    await _db.insert(tableName, expense);
  }

  ///passing in null values for where and targetValues deletes the whole table specified by tableName
  Future<void> delete ({@required String tableName, String where, List<dynamic> targetValues}) async {
    await _db.delete(tableName: tableName, where: where, targetValues: targetValues);
  }

  Future<void> update (String tableName, int id, Expense expense) async {
    await _db.update(tableName, id, expense);
  }

  ///if whereArgs contains instance of DateTime, ensure to obtain the equivalent in millisecondSinceEpoch
  Future<List<Expense>> getAll (String tableName, {String where, List<dynamic> whereArgs}) async {
    return await _db.getAll(tableName, where: where, whereArgs: whereArgs);
  }

  Future<List<List<Expense>>> batchGet (String tableName, String where, List<DateTime> whereArgs) async {
    return await _db.batchGet(tableName, where, whereArgs);
  }

  //******************************************shared preferences********************************************************
  ChartDataDateRange get chartDataDateRange => _sharedPrefs.chartDataDateRange;
  bool get dateRangeAutoGen => _sharedPrefs.dateRangeAutoGen;
  String get currencySymbol => _sharedPrefs.currencySymbol;
  DateTime get oldestDate => _sharedPrefs.oldestDate;

  Future<void> setNewOldestDate (DateTime oldestDate) async {
    _sharedPrefs.setNewOldestDate(oldestDate);
  }

  Future<void> setChartDataDateRange(ChartDataDateRange chartDataDateRange) async {
    await _sharedPrefs.setChartDataDateRange(chartDataDateRange);
  }

  Future setCurrencySymbol (String newSymbol ) async {
    await _sharedPrefs.setCurrencySymbol(newSymbol);
  }

  Future toggleDateRangeAutoGen (bool autoGen) async {
    await _sharedPrefs.toggleDateRangeAutoGen(autoGen);
  }
}