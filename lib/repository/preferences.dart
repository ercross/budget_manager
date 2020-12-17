import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chart_data_date_range.dart';

class Preferences{

  Preferences._();

  static final Preferences preferences = Preferences._();

  //all settings variable stored in shared_preferences
  //direct access not provided to ensure proper initialization before
  static ChartDataDateRange _chartDataDateRange;
  static bool dateRangeAutoGen;
  static String currencySymbol;

  ChartDataDateRange get chartDataDateRange => _chartDataDateRange;

  ///initsharedPrefs initializes all settings variable to either a default value or the value previously entered by user
  ///initsharedPrefs must be invoked on application start
  static Future<void> loadSettings () async {
    final sharedPrefs = await SharedPreferences.getInstance();
    preferences._initDateRangeAutoGen(sharedPrefs);
    preferences._initChartDataDateRange(sharedPrefs, dateRangeAutoGen);
    preferences._initCurrencySymbol(sharedPrefs);
  }

  void _initDateRangeAutoGen (SharedPreferences sharedPrefs) {
    if (dateRangeAutoGen == null) 
      dateRangeAutoGen = true;
    dateRangeAutoGen = sharedPrefs.getBool(_Keys._dateRangeAutoGen);
  }

  void _initCurrencySymbol(SharedPreferences sharedPrefs) {
    if (currencySymbol == null) 
      currencySymbol = "\$";
    currencySymbol = sharedPrefs.getString(_Keys._currencySymbol);
  }

  void _initChartDataDateRange (SharedPreferences sharedPrefs, bool dateRangeAutoGen) {
    if (dateRangeAutoGen != null && dateRangeAutoGen == true) {
      _setDefaultDateRange(sharedPrefs);
      return;
    }

    //the code inside the if statement below is the same as that above, but will only run once when the app is started for the first time
    //the separation allows a quick return should dateRangeAutoGen be set to true
    _chartDataDateRange = _fetchChartDataDateRange(sharedPrefs); 
    if (_chartDataDateRange == null) {
      _setDefaultDateRange(sharedPrefs);
    }
  }

  //setDefaultTimeRange sets the time to the default value, i.e., auto generation of date range daily
  void _setDefaultDateRange(SharedPreferences sharedPrefs) {
    final DateTime date = DateTime.now();
    _setChartDataDateRange( 
      sharedPrefs: sharedPrefs, 
      chartDataDateRange: ChartDataDateRange(
        toDate: DateTime(date.year, date.month, date.day),
        fromDate: DateTime(date.year, date.month, date.day).subtract(Duration(days: 6)))
    );
  }

  ///fetchChartDataDateRange() returns null if chartDataDateRange is null
  ChartDataDateRange _fetchChartDataDateRange(SharedPreferences sharedPrefs) {
    final textRep = sharedPrefs.getString(_Keys._chartDataDateRange);
    if (textRep != null) {
      final Map<String, dynamic> map = jsonDecode(textRep) as Map<String, dynamic>;
      if (map != null) {
        return ChartDataDateRange.fromMap(map);
      }
    }
    return null;
  }

  Future<void> setChartDataDateRange (ChartDataDateRange dateRange) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    _setChartDataDateRange(sharedPrefs: sharedPrefs, chartDataDateRange: dateRange);
  }

  //this is the only method through which the value of the class static variable, _chartDataDateRange was set
  //@param sharedPrefs required to use the same instance of SharedPreference while calling this method in other private methods 
  Future<void> _setChartDataDateRange({@required SharedPreferences sharedPrefs, @required ChartDataDateRange chartDataDateRange}) async {
    _chartDataDateRange = chartDataDateRange;
    await sharedPrefs.setString(_Keys._chartDataDateRange, jsonEncode(chartDataDateRange.toMap()));
  }
}


class _Keys{
  static const String _chartDataDateRange = "chartDataDateRange";
  static const String _dateRangeAutoGen = "dateRangeAutoGen";
  static const String _currencySymbol = "currencySymbol";
}