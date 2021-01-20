import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'db_tables.dart';

part 'database_provider.dart';
part 'preferences.dart';

///The app would be using more than one persistence option, 
///This repository is provided as an abstraction to these persistence options
class Repository {

  Repository._();

  static final Repository repository = Repository._();
  final DatabaseProvider _db = DatabaseProvider.databaseProvider;
  final Preferences _sharedPrefs = Preferences.preferences;

  Future<void> insert (String tableName, Map<String,dynamic> item) async {
    await _db.insert(tableName, item);
  }

  ///passing in null values for where and targetValues deletes the whole table specified by tableName
  Future<void> delete ({@required String tableName, String where, List<dynamic> targetValues}) async {
    await _db.delete(tableName: tableName, where: where, targetValues: targetValues);
  }

  ///if whereArgs contains instance of DateTime, ensure to obtain the equivalent in millisecondSinceEpoch
  ///cast return value to appropriate dataType
  Future<List<Map<String, dynamic>>> fetch (String tableName, {String where, List<dynamic> whereArgs}) async {
    return await _db.fetch(tableName, where: where, whereArgs: whereArgs);
  }

  ///batchGet fetches items from table named @param tableName.
  ///If needed items can be fetched in one operation, please use getAll()
  Future<List<List<Map<String, dynamic>>>> batchFetch (String tableName, String where, List<DateTime> whereArgs) async {
    return await _db.batchFetch(tableName, where, whereArgs);
  }

  //******************************************shared preferences********************************************************
  String get currency => _sharedPrefs.currency;
  DateTime get oldestExpenseDate => _sharedPrefs.oldestExpenseDate;
  DateTime get oldestIncomeDate => _sharedPrefs.oldestIncomeDate;
  DateTime get lastReportDate => _sharedPrefs.lastReportDate;

  Future<void> setOldestExpenseDate (DateTime oldestDate) async {
    _sharedPrefs.setOldestExpenseDate(oldestDate);
  }

  Future<void> setOldestIncomeDate (DateTime oldestDate) async {
    _sharedPrefs.setOldestIncomeDate(oldestDate);
  }

  Future setNewCurrency (String currency ) async {
    await _sharedPrefs.setCurrency(currency);
  }

  void setLastReportDate (DateTime lastReportDate) {
    _sharedPrefs.setLastReportDate(lastReportDate);
  }
}