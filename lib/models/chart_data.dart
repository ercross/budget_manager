import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:trackIt/models/income.dart';

import '../models/chart_data_date_range.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import 'chart_data_date_range.dart';
import 'expense.dart';

enum ChartType {daily, monthly}

class ChartData extends Equatable {

  final ChartType chartType;
  final ChartDataDateRange dateRange;

  double totalAmount = 0;

  /* Lists in dart are ordered according to entry position
  ** So barTitles[1] maps onto expensesPerDate[1], durationUnitTotal[1], percentageSpentPerDay[1], dates[1].
  ** All list instance initialized with initial capacity = 7 since the chart is built to populate a 7-day data at a time
  */

  ///barTitles is the text output under the chart rods
  List<String> barTitles = List<String>(7);

  ///durationUnitTotal contains the total amount of income or expense for each month or each day contained in chartDateRange
  List<double> timeUnitTotal = List<double>(7);
  List<double> percentPerTimeUnit = List<double>(7);
  List<DateTime> dates = List<DateTime>(7);

  //This constructor is the entry point to this class. 
  ///Note that toDate must be closer to DateTime.now() than fromDate. In other words, toDate must be greater than fromDate
  ///setChartData must be invoked on this instance to set the fields of this instance
  ChartData(this.dateRange, this.chartType);

  ///ChartData._loaded was only used to bind and export barTitles, expensesPerDate, and durationUnitTotal into one object
  ///so setChartData can return all within a single object.
  ChartData._loaded({this.chartType,
      this.dateRange, 
      @required this.barTitles,
      @required this.totalAmount,
      @required this.timeUnitTotal,
      @required this.percentPerTimeUnit,
      @required this.dates});

  @override
  List<Object> get props => [
        dateRange,
        totalAmount,
        barTitles,
        timeUnitTotal,
        dates
      ];

  ///generateChartData calculates and return the statistics to be displayed by a BarChart
  ///returns null if no data was found for the data range
  ///if ChartType is daily, the closest date to TimeDate.now() is returned as day7 in index 6
  Future<ChartData> generateChartData() async {
      if (dateRange == null) return null;
      if (chartType == ChartType.daily) return _generateDailyChartData();
       if (chartType == ChartType.monthly) return _generateMonthlyChartData();
  }

  Future<ChartData> _generateMonthlyChartData () async {
    final List<DateTime> _dates = _calculateDates();
    final List<List<Income>> _incomes = await _fetchIncomes(_dates);
    final double _totalAmount = _calculateTotalIncome(_incomes);
    final List<String> _monthNames = _getMonthNames(_dates);
    final List<double> _eachMonthsTotal = _calculateMonthlyIncome(_incomes);
    final List<double> _percentPerMonth = _calculatePercentPerTimeUnit(_eachMonthsTotal, _totalAmount);
    return ChartData._loaded(
        barTitles: _monthNames,
        totalAmount: _totalAmount,
        timeUnitTotal: _eachMonthsTotal,
        percentPerTimeUnit: _percentPerMonth,
        dates: _dates);
  }

  Future<ChartData> _generateDailyChartData () async {
    final List<DateTime> _dates = _calculateDates();
    final List<List<Expense>> _expenses = await _fetchExpenses(_dates);
    if(_expenses.isEmpty) {
      return null;
    }
    final double _totalAmount = _calculateTotalExpenses(_expenses);
    final List<String> _weekdaysNames = _getWeekdaysNames(_dates);
    final List<double> _dailyExpensesTotal = _calculateDailyExpenses(_expenses);
    final List<double> _percentageSpentPerDay = _calculatePercentPerTimeUnit(_dailyExpensesTotal, _totalAmount);

    return ChartData._loaded(
        barTitles: _weekdaysNames,
        totalAmount: _totalAmount,
        timeUnitTotal: _dailyExpensesTotal,
        percentPerTimeUnit: _percentageSpentPerDay,
        dates: _dates);
  }

  List<double> _calculatePercentPerTimeUnit(List<double> _durationUnitTotal, double _totalAmount) {
    final List<double> _percentPerTimeUnit = List<double>();
    double timeUnitPercent = 0;
    for (int i=0; i<_durationUnitTotal.length; i++) {
      timeUnitPercent = 0;

      if (_durationUnitTotal[i] == 0) {
        _percentPerTimeUnit.add(0);
        continue;
      }

      timeUnitPercent = (_durationUnitTotal[i] * 100) / _totalAmount;
      _percentPerTimeUnit.add(double.parse(timeUnitPercent.toStringAsFixed(2)));
    }
    return _percentPerTimeUnit;
  }

  ///calculateMonthlyIncome calculates the total income for each month within this.dateRange
  List<double> _calculateMonthlyIncome(List<List<Income>> monthlyIncome) {
    List<double> _eachMonthsTotal = List<double>();
    double thisMonthTotal = 0;

    for (int i = 0; i < monthlyIncome.length; i++) {
      thisMonthTotal = 0;

      if (monthlyIncome[i].isEmpty) {
        _eachMonthsTotal.add(0);
        continue;
      }
      else {
        monthlyIncome[i].forEach((income) {
        thisMonthTotal += income.amount;
        });
      }
      _eachMonthsTotal.add(thisMonthTotal);
    }
    return _eachMonthsTotal;
  }

  ///calculateDailyExpensesTotal calculates the total amount spent on expenses for each day within the ChartDataDateRange
  List<double> _calculateDailyExpenses(List<List<Expense>> dailyExpense) {
    List<double> _dailyExpensesTotal = List<double>();
    double dailyTotal;

    for (int i = 0; i < dailyExpense.length; i++) {
      dailyTotal = 0;

      if (dailyExpense[i].isEmpty) {
        _dailyExpensesTotal.add(0);
        continue;
      }

      dailyExpense[i].forEach((expense) {
        dailyTotal += expense.amount;
      });

      _dailyExpensesTotal.add(dailyTotal);
    }
    return _dailyExpensesTotal;
  }

  //only the first two letters of each weekday is saved in each list element
  List<String> _getWeekdaysNames(List<DateTime> dates) {
    final DateFormat dateFormat = DateFormat('EEEE'); //outputs only the weekday name
    final List<String> barTitles = List<String>();
    barTitles.add(dateFormat.format(dates[0]).substring(0, 2));
    barTitles.add(dateFormat.format(dates[1]).substring(0, 2));
    barTitles.add(dateFormat.format(dates[2]).substring(0, 2));
    barTitles.add(dateFormat.format(dates[3]).substring(0, 2));
    barTitles.add(dateFormat.format(dates[4]).substring(0, 2));
    barTitles.add(dateFormat.format(dates[5]).substring(0, 2));
    barTitles.add(dateFormat.format(dates[6]).substring(0, 2));

    return barTitles;
  }

  List<String> _getMonthNames(List<DateTime> dates) {
    final DateFormat dateFormat = DateFormat('MMMM');
    final List<String> barTitles = List<String>(); //outputs only the month name
    barTitles.add(dateFormat.format(dates[0]).substring(0, 3));
    barTitles.add(dateFormat.format(dates[1]).substring(0, 3));
    barTitles.add(dateFormat.format(dates[2]).substring(0, 3));
    barTitles.add(dateFormat.format(dates[3]).substring(0, 3));
    barTitles.add(dateFormat.format(dates[4]).substring(0, 3));
    barTitles.add(dateFormat.format(dates[5]).substring(0, 3));
    barTitles.add(dateFormat.format(dates[6]).substring(0, 3));

    return barTitles;
  }

  Future<List<List<Income>>> _fetchIncomes (List<DateTime> _dates) async {
    final List<List<Map<String, dynamic>>> mapsList = await Repository.repository
        .batchFetch(IncomeTable.tableName, "${IncomeTable.columnMonth}=?", _dates);
    final List<List<Income>> incomes = List<List<Income>>();
    mapsList.forEach( (maps) => incomes.add(Income.fromMaps(maps)));
    return incomes;
  }

  //each expense list in the outer list correspond to each day numerically. For example list[0] in expenses is day1 expense list
  Future<List<List<Expense>>> _fetchExpenses(List<DateTime> _dates) async {
    final List<List<Map<String, dynamic>>> mapsList = await Repository.repository.batchFetch(
        ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", _dates);
    final List<List<Expense>> expenses = List<List<Expense>>();
    mapsList.forEach((maps) => expenses.add(Expense.fromMaps(maps)));
    return expenses;
  }

  ///_calculateDates calculates the date of each duration unit
  ///For example, daily dates contained within dateRange.from to dateRange.toDate if chartType == ChartType.daily
  ///monthly dates otherwise
  List<DateTime> _calculateDates() {
    final List<DateTime> _dates = List<DateTime>();
    switch (chartType) {
      case ChartType.daily:
        final int numberOfDays = 7;
        for (int i=0; i<numberOfDays; i++) {
          _dates.add(dateRange.fromDate.add(Duration(days: i)));
        }
        break;
      case ChartType.monthly:
        int year = dateRange.fromDate.year;
        int month = dateRange.fromDate.month;
        for (int i=0, j=0; i<7 ; i++, j++) {
          if (month+j == 13) {
            year += 1;
            month = 0;
            j = 1;
          }
          _dates.add(DateTime(year, month+j));
        }
        break;
    }
    return _dates;
  }

  ///this.totalAmount calculated here to avoid another looping over the unsortedExpenses
  double _calculateTotalExpenses(List<List<Expense>> expenses) {
    double totalAmount = 0;
    expenses.forEach((expenseList) {
      expenseList.forEach((expense) {
        totalAmount += expense.amount;
      });
    });
    return totalAmount;
  }

  double _calculateTotalIncome (List<List<Income>> incomes) {
    double totalAmount = 0;
    incomes.forEach((incomesList) {
      incomesList.forEach((income) {
        totalAmount += income.amount;
      });
    });
    return totalAmount;
  }

  String toString() {
    return "totalAmount: $totalAmount\n" +
            "date: $dates\n" +
            "barTitles: $barTitles\n" +
            "timeUnitTotal: $timeUnitTotal\n" +
            "percentPerTimeUnit: $percentPerTimeUnit\n";
  }
}
