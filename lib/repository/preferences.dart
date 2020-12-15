import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chart_data_date_range.dart';

class Preferences{

  Preferences._();

  static final Preferences prefs = Preferences._();

  ChartDataDateRange _chartDataDateRange;

  ChartDataDateRange get chartDataDateRange{
    if (_chartDataDateRange == null) {
      final DateTime date = DateTime.now();
      return _chartDataDateRange = ChartDataDateRange(
        toDate: DateTime(date.year, date.month, date.day),
        fromDate: DateTime(date.year, date.month, date.day).subtract(Duration(days: 6)));
    }
    return _chartDataDateRange;
  }

  ///fetchChartDataDateRange() returns null if chartDataDateRange is null
  Future<ChartDataDateRange> fetchChartDataDateRange() async {
    final prefs = await SharedPreferences.getInstance();
    final textRep = prefs.getString(_SharedPreferencesKeys._chartDataDateRange);
    if (textRep != null) {
      final map = JsonEncoder().convert(textRep) as Map<String, dynamic>;
      return ChartDataDateRange.fromMap(map);
    }
    return null;
  }

  Future<void> setChartDataDateRange(ChartDataDateRange chartDataDateRange) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final map = chartDataDateRange.toMap();
    final textRep = JsonEncoder().convert(map);
    prefs.setString(_SharedPreferencesKeys._chartDataDateRange, textRep);
    _chartDataDateRange = chartDataDateRange;
  }
}

class _SharedPreferencesKeys{
  static const String _chartDataDateRange = "chartDataDateRange";
}