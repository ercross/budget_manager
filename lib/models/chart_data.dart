import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../models/chart_data_date_range.dart';
import '../repository/database_provider.dart';
import 'chart_data_date_range.dart';
import 'expense.dart';

class ChartData extends Equatable{
  
  final ChartDataDateRange chartDataDateRange;

  ///value calculated inside sortByDate()
  double totalAmount = 0; 

  ///Both values depends on that Lists in dart are ordered according to entry position
  ///So weekdaysNames[1] maps onto expensesPerDate[1]. 
  ///More simply, the expenses of day N, say day1, in ChartDataDateRange is found in expensesPerDate[N], i.e., expensesPerDate[1]
  ///Note that day1 is the farthest day from DateTime.now(), i.e., chartDataDateRange.fromDate in this context
  List<String> weekdaysNames = List<String>(7); 
  List<List<Expense>> expensesPerDate = List<List<Expense>>(7);
  List<double> dailyExpensesTotal = List<double>(7);
  List<DateTime> dates = List<DateTime>(7);
  
  ///Note that toDate must be closer to today's date than fromDate. In other words, toDate must be greater than fromDate
  ///setChartData must be invoked on this instance to set the fields of this instance
  ChartData(this.chartDataDateRange);

  ///ChartData._loaded was only used to bind weekdaysNames, expensesPerDate, and dailyExpensesTotal into one object
  ///so setChartData can return all with one return statement.
  ChartData._loaded ({this.chartDataDateRange, 
                    @required this.weekdaysNames, 
                    @required this.totalAmount, 
                    @required this.expensesPerDate,
                    @required this.dailyExpensesTotal,
                    @required this.dates});

  @override
  List<Object> get props => [chartDataDateRange, totalAmount, weekdaysNames, expensesPerDate, dailyExpensesTotal];

  ///The closest date to TimeDate.now() is returned as day7 in index 7 
  ///return data structure break down: 
  ///Outer List index = DateTime.weekday e.g., returns 1 for Monday, 2 for Tuesday
  ///Map<weekdayName, expensesOnThisDay>
  Future<ChartData> setChartData() async {
    final List<DateTime> _dates = _calculateDates();
    final List<List<Expense>> _expenses = await _fetchDateRangeExpenses(_dates);
    final double _totalAmount = _calculateTotalAmount(_expenses);
    if (_expenses.isNotEmpty) {
      for (int i = 0; i<_expenses.length; i++) {
      print("List number: $i \nList size: ${_expenses[i].length}");
      _expenses[i].forEach((expense) { print("List content: ${expense.toString()}");});
    }
    }
    final List<String>_weekdaysNames = _getWeekdaysNames(_dates);
    final List<double> _dailyExpensesTotal = _calculateDailyExpensesTotal(_expenses);

    return ChartData._loaded(
      weekdaysNames: _weekdaysNames, 
      totalAmount: _totalAmount == null ? 0 : _totalAmount, 
      expensesPerDate: _expenses, 
      dailyExpensesTotal: _dailyExpensesTotal,
      dates: _dates);
  }

  List<double> _calculateDailyExpensesTotal(List<List<Expense>> expensesPerDate) {
    List<double> dailyExpensesTotal = List<double>();
    double dailyTotal = 0;

    for (int i=0; i<expensesPerDate.length; i++) {
      expensesPerDate[i].forEach((expense) { dailyTotal += expense.amount; });
      dailyExpensesTotal.add(dailyTotal);
    }
    return dailyExpensesTotal;
  }

  //only the first two letters of each weekday is saved in each list element
  List<String> _getWeekdaysNames (List<DateTime> dates) {
    final DateFormat dateFormat = DateFormat('EEEE'); //outputs only the weekday name
    final List<String> weekdaysNames = List<String>();
    weekdaysNames.add(dateFormat.format(dates[0]).substring(0,2));
    weekdaysNames.add(dateFormat.format(dates[1]).substring(0,2));
    weekdaysNames.add(dateFormat.format(dates[2]).substring(0,2));
    weekdaysNames.add(dateFormat.format(dates[3]).substring(0,2));
    weekdaysNames.add(dateFormat.format(dates[4]).substring(0,2));
    weekdaysNames.add(dateFormat.format(dates[5]).substring(0,2));
    weekdaysNames.add(dateFormat.format(dates[6]).substring(0,2));

    return weekdaysNames;
  }

  //each expense list in the outer list correspond to each day numerically. For example list[0] in expenses is day1 expense list
  Future<List<List<Expense>>> _fetchDateRangeExpenses (List<DateTime> dates) async {
    final DatabaseProvider db = DatabaseProvider.databaseProvider;
    List<List<Expense>> expenses = await db.batchGet(ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", dates);
    return expenses;
  }

  List<DateTime> _calculateDates (){
    final f = chartDataDateRange.fromDate;
    final t = chartDataDateRange.toDate;
    
    final DateTime day1Date = DateTime(f.year, f.month, f.day);
    final DateTime day2Date = DateTime(t.year, t.month, t.subtract(Duration(days: 5)).day);
    final DateTime day3Date = DateTime(t.year, t.month, t.subtract(Duration(days: 4)).day);
    final DateTime day4Date = DateTime(t.year, t.month, t.subtract(Duration(days: 3)).day);
    final DateTime day5Date = DateTime(t.year, t.month, t.subtract(Duration(days: 2)).day);
    final DateTime day6Date = DateTime(t.year, t.month, t.subtract(Duration(days: 1)).day);
    final DateTime day7Date = DateTime(t.year, t.month, t.day);

    List<DateTime> dates = List<DateTime>();

    dates.add(DateTime(day1Date.year, day1Date.month, day1Date.day));
    dates.add(DateTime(day2Date.year, day2Date.month, day2Date.day));
    dates.add(DateTime(day3Date.year, day3Date.month, day3Date.day));
    dates.add(DateTime(day4Date.year, day4Date.month, day4Date.day));
    dates.add(DateTime(day5Date.year, day5Date.month, day5Date.day));
    dates.add(DateTime(day6Date.year, day6Date.month, day6Date.day));
    dates.add(DateTime(day7Date.year, day7Date.month, day7Date.day));
    print("day 1 date is: $day1Date");
    return dates;
  }

  ///this.totalAmount calculated here to avoid another looping over the unsortedExpenses
  double _calculateTotalAmount (List<List<Expense>> expenses) {
    double totalAmount = 0;
    expenses.forEach((expenseList) { 
      expenseList.forEach((expense) { totalAmount += expense.amount;});
    });
    return totalAmount;
  }
}