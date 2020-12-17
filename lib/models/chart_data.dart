import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../models/chart_data_date_range.dart';
import '../repository/database_provider.dart';
import 'chart_data_date_range.dart';
import 'expense.dart';

class ChartData extends Equatable {

  final ChartDataDateRange chartDataDateRange;

  double totalAmount = 0;

  //Lists in dart are ordered according to entry position
  //So weekdaysNames[1] maps onto expensesPerDate[1], dailyExpensesTotal[1], percentageSpentPerDay[1], dates[1].
  //All list instance initialized with initial capacity = 7 since the chart is built to populate a 7-day data at a time
  List<String> weekdaysNames = List<String>(7);
  List<List<Expense>> expensesPerDate = List<List<Expense>>(7);

  ///dailyExpensesTotal is the total amount spent on expenses per date contained in chartDataDateRange.fromDate
  List<double> dailyExpensesTotal = List<double>(7);
  List<double> percentageSpentPerDay = List<double>(7);
  List<DateTime> dates = List<DateTime>(7);

  //This constructor is the entry point to this class. 
  ///Note that toDate must be closer to DateTime.now() than fromDate. In other words, toDate must be greater than fromDate
  ///setChartData must be invoked on this instance to set the fields of this instance
  ChartData(this.chartDataDateRange);

  ///ChartData._loaded was only used to bind and export weekdaysNames, expensesPerDate, and dailyExpensesTotal into one object
  ///so setChartData can return all with one return statement.
  ChartData._loaded(
      {this.chartDataDateRange,
      @required this.weekdaysNames,
      @required this.totalAmount,
      @required this.expensesPerDate,
      @required this.dailyExpensesTotal,
      @required this.percentageSpentPerDay,
      @required this.dates});

  @override
  List<Object> get props => [
        chartDataDateRange,
        totalAmount,
        weekdaysNames,
        expensesPerDate,
        dailyExpensesTotal,
        dates
      ];

  ///The closest date to TimeDate.now() is returned as day7 in index 6
  ///return data structure break down:
  ///Outer List index = DateTime.weekday e.g., returns 1 for Monday, 2 for Tuesday
  ///Map<weekdayName, expensesOnThisDay>
  ///setChartData() returns null if no expenses were found for the data range
  Future<ChartData> setChartData() async {
    if (this.chartDataDateRange == null) {
      return null;
    }
    final List<DateTime> _dates = _calculateDates();
    final List<List<Expense>> _expenses = await _fetchDateRangeExpenses(_dates);
    if(_expenses.isEmpty) {
      return null;
    }
    List<List<Expense>> _sortedExpenses = _sortExpenses(_expenses, _dates);
    final double _totalAmount = _calculateTotalAmount(_sortedExpenses);
    final List<String> _weekdaysNames = _getWeekdaysNames(_dates);
    final List<double> _dailyExpensesTotal = _calculateDailyExpensesTotal(_sortedExpenses);
    final List<double> _percentageSpentPerDay = _calculatePercentageSpentPerDay(_dailyExpensesTotal, _totalAmount);

    return ChartData._loaded(
        weekdaysNames: _weekdaysNames,
        totalAmount: _totalAmount,
        expensesPerDate: _sortedExpenses,
        dailyExpensesTotal: _dailyExpensesTotal,
        percentageSpentPerDay: _percentageSpentPerDay,
        dates: _dates);
  }

  List<double> _calculatePercentageSpentPerDay(List<double> _dailyExpensesTotal, double _totalAmount) {
    List<double> _percentageSpentPerDay = List<double>();
    double dailyPercentage;
    for (int i=0; i<_dailyExpensesTotal.length; i++) {
      dailyPercentage = 0;

      if (_dailyExpensesTotal[i] == 0) {
        _percentageSpentPerDay.add(0);
        continue;
      }

      dailyPercentage = (_dailyExpensesTotal[i] * 100) / _totalAmount;
      _percentageSpentPerDay.add(double.parse(dailyPercentage.toStringAsFixed(2)));
    }

    return _percentageSpentPerDay;
  }

  List<List<Expense>> _sortExpenses(List<List<Expense>> expenses, List<DateTime> dates) {
    var day1Expenses = List<Expense>(),
        day2Expenses = List<Expense>(),
        day3Expenses = List<Expense>(),
        day4Expenses = List<Expense>(),
        day5Expenses = List<Expense>(),
        day6Expenses = List<Expense>(),
        day7Expenses = List<Expense>();

    for (int i = 0; i < expenses.length; i++) {
      expenses[i].forEach((expense) {

        if (expense.date.isAtSameMomentAs(dates[0]) &&
            !day1Expenses.contains(expense)) {
          day1Expenses.add(expense);
        } 

        else if (expense.date.isAtSameMomentAs(dates[1]) &&
            !day2Expenses.contains(expense)) {
          day2Expenses.add(expense);
        }

        else if (expense.date.isAtSameMomentAs(dates[2]) &&
            !day3Expenses.contains(expense)) {
          day3Expenses.add(expense);
        }

        else if (expense.date.isAtSameMomentAs(dates[3]) &&
            !day4Expenses.contains(expense)) {
          day4Expenses.add(expense);
        }

        else if (expense.date.isAtSameMomentAs(dates[4]) &&
            !day5Expenses.contains(expense)) {
          day5Expenses.add(expense);
        }

        else if (expense.date.isAtSameMomentAs(dates[5]) &&
            !day6Expenses.contains(expense)) {
          day6Expenses.add(expense);
        }

        else if (expense.date.isAtSameMomentAs(dates[6]) &&
            !day7Expenses.contains(expense)) {
          day7Expenses.add(expense);
        }
      });
    }

    final List<List<Expense>> sortedExpenses = List<List<Expense>>();

    sortedExpenses.add(day1Expenses);
    sortedExpenses.add(day2Expenses);
    sortedExpenses.add(day3Expenses);
    sortedExpenses.add(day4Expenses);
    sortedExpenses.add(day5Expenses);
    sortedExpenses.add(day6Expenses);
    sortedExpenses.add(day7Expenses);

    return sortedExpenses;
  }

  ///calculateDailyExpensesTotal calculates the total amount spent on expenses for each day within the ChartDataDateRange
  List<double> _calculateDailyExpensesTotal(List<List<Expense>> expensesPerDate) {
    List<double> _dailyExpensesTotal = List<double>();
    double dailyTotal;

    for (int i = 0; i < expensesPerDate.length; i++) {
      dailyTotal = 0;

      if (expensesPerDate[i].isEmpty) {
        _dailyExpensesTotal.add(0);
        continue;
      }

      expensesPerDate[i].forEach((expense) {
        dailyTotal += expense.amount;
      });

      _dailyExpensesTotal.add(dailyTotal);
    }
    return _dailyExpensesTotal;
  }

  //only the first two letters of each weekday is saved in each list element
  List<String> _getWeekdaysNames(List<DateTime> dates) {
    final DateFormat dateFormat =
        DateFormat('EEEE'); //outputs only the weekday name
    final List<String> weekdaysNames = List<String>();
    weekdaysNames.add(dateFormat.format(dates[0]).substring(0, 2));
    weekdaysNames.add(dateFormat.format(dates[1]).substring(0, 2));
    weekdaysNames.add(dateFormat.format(dates[2]).substring(0, 2));
    weekdaysNames.add(dateFormat.format(dates[3]).substring(0, 2));
    weekdaysNames.add(dateFormat.format(dates[4]).substring(0, 2));
    weekdaysNames.add(dateFormat.format(dates[5]).substring(0, 2));
    weekdaysNames.add(dateFormat.format(dates[6]).substring(0, 2));

    return weekdaysNames;
  }

  //each expense list in the outer list correspond to each day numerically. For example list[0] in expenses is day1 expense list
  Future<List<List<Expense>>> _fetchDateRangeExpenses(
      List<DateTime> dates) async {
    final DatabaseProvider db = DatabaseProvider.databaseProvider;
    List<List<Expense>> expenses = await db.batchGet(
        ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", dates);
    return expenses;
  }

  //todo refactor code using the logic used in ChartBloc()._dateIsContainedIn
  List<DateTime> _calculateDates() {

    final f = chartDataDateRange.fromDate;
    final t = chartDataDateRange.toDate;

    final DateTime day1Date = DateTime(f.year, f.month, f.day);
    final DateTime day2Date =
        DateTime(t.year, t.month, t.subtract(Duration(days: 5)).day);
    final DateTime day3Date =
        DateTime(t.year, t.month, t.subtract(Duration(days: 4)).day);
    final DateTime day4Date =
        DateTime(t.year, t.month, t.subtract(Duration(days: 3)).day);
    final DateTime day5Date =
        DateTime(t.year, t.month, t.subtract(Duration(days: 2)).day);
    final DateTime day6Date =
        DateTime(t.year, t.month, t.subtract(Duration(days: 1)).day);
    final DateTime day7Date = DateTime(t.year, t.month, t.day);

    List<DateTime> dates = List<DateTime>();

    dates.add(DateTime(day1Date.year, day1Date.month, day1Date.day));
    dates.add(DateTime(day2Date.year, day2Date.month, day2Date.day));
    dates.add(DateTime(day3Date.year, day3Date.month, day3Date.day));
    dates.add(DateTime(day4Date.year, day4Date.month, day4Date.day));
    dates.add(DateTime(day5Date.year, day5Date.month, day5Date.day));
    dates.add(DateTime(day6Date.year, day6Date.month, day6Date.day));
    dates.add(DateTime(day7Date.year, day7Date.month, day7Date.day));
    return dates;
  }

  ///this.totalAmount calculated here to avoid another looping over the unsortedExpenses
  double _calculateTotalAmount(List<List<Expense>> expenses) {
    double totalAmount = 0;
    expenses.forEach((expenseList) {
      expenseList.forEach((expense) {
        totalAmount += expense.amount;
      });
    });
    return totalAmount;
  }
}
