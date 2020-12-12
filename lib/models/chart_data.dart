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
  
  ///Note that toDate must be closer to today's date than fromDate. In other words, toDate must be greater than fromDate
  ///setChartData must be invoked on this instance to set the fields of this instance
  ChartData(this.chartDataDateRange);

  ///ChartData._loaded was only used to bind weekdaysNames, expensesPerDate, and dailyExpensesTotal into one object
  ///so setChartData can return all with one return statement.
  ChartData._loaded ({this.chartDataDateRange, 
                    @required this.weekdaysNames, 
                    @required this.totalAmount, 
                    @required this.expensesPerDate,
                    @required this.dailyExpensesTotal});

  @override
  List<Object> get props => [chartDataDateRange, totalAmount, weekdaysNames, expensesPerDate, dailyExpensesTotal];

  ///The closest date to TimeDate.now() is returned as day7 in index 7 
  ///return data structure break down: 
  ///Outer List index = DateTime.weekday e.g., returns 1 for Monday, 2 for Tuesday
  ///Map<weekdayName, expensesOnThisDay>
  Future<ChartData> setChartData() async {
    final List<String> dates = _calculateDates();
    List<List<Expense>> unsortedExpenses = await _fetchDateRangeExpenses(dates);
    //expensesPerDate = _getExpensesPerDate(unsortedExpenses, dates);
    weekdaysNames = _getWeekdaysNames(dates);
    dailyExpensesTotal = _calculateDailyExpensesTotal(unsortedExpenses);

    return ChartData._loaded(
      weekdaysNames: weekdaysNames, 
      totalAmount: totalAmount, 
      expensesPerDate: expensesPerDate, 
      dailyExpensesTotal: dailyExpensesTotal);
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

  List<String> _getWeekdaysNames (List<String> dates) {
    final List<String> weekdaysNames = List<String>();
    weekdaysNames.add(dates[0].substring(0,2));
    weekdaysNames.add(dates[1].substring(0,2));
    weekdaysNames.add(dates[2].substring(0,2));
    weekdaysNames.add(dates[3].substring(0,2));
    weekdaysNames.add(dates[4].substring(0,2));
    weekdaysNames.add(dates[5].substring(0,2));
    weekdaysNames.add(dates[6].substring(0,2));

    return weekdaysNames;
  }

  Future<List<List<Expense>>> _fetchDateRangeExpenses (List<String> dates) async {
    final DatabaseProvider db = DatabaseProvider.databaseProvider;
    List<List<Expense>> expenses = await db.batchGet(ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", dates);
    return expenses;
  }

  ///The list values could have been added on the line each was created, making the method shorter
  ///But the clarity this long one provides is preferred to the short devil
  List<String> _calculateDates (){
    final DateFormat dateFormat = DateFormat('EEEE, yMMMMd');
    
    final String day1Date = dateFormat.format(chartDataDateRange.fromDate);
    final String day2Date = dateFormat.format(chartDataDateRange.toDate.subtract(Duration(days: 5)));
    final String day3Date = dateFormat.format(chartDataDateRange.toDate.subtract(Duration(days: 4)));
    final String day4Date = dateFormat.format(chartDataDateRange.toDate.subtract(Duration(days: 3)));
    final String day5Date = dateFormat.format(chartDataDateRange.toDate.subtract(Duration(days: 2)));
    final String day6Date = dateFormat.format(chartDataDateRange.toDate.subtract(Duration(days: 1)));
    final String day7Date = dateFormat.format(chartDataDateRange.toDate);

    List<String> dates = List<String>();

    dates.add(day1Date);
    dates.add(day2Date);
    dates.add(day3Date);
    dates.add(day4Date);
    dates.add(day5Date);
    dates.add(day6Date);
    dates.add(day7Date);

    return dates;
  }

  ///this.totalAmount calculated here to avoid another looping over the unsortedExpenses
  List<List<Expense>> _getExpensesPerDate (List<List<Expense>> expenses, List<String> dates) {
    List<Expense> day1Expenses, day2Expenses, day3Expenses, day4Expenses, day5Expenses, day6Expenses, day7Expenses;

    for (int i=0; i<expenses.length;i++) {
      expenses[i].forEach((expense) { 
      this.totalAmount += expense.amount; 

      if (expense.date.toString().compareTo(dates[0]) == 0) {
        day1Expenses.add(expense);
      }

      else if (expense.date.toString().compareTo(dates[1]) == 0){
        day2Expenses.add(expense);
      }

      else if (expense.date.toString().compareTo(dates[2]) == 0){
        day3Expenses.add(expense);
      }

      else if (expense.date.toString().compareTo(dates[3]) == 0){
        day4Expenses.add(expense);
      }

      else if (expense.date.toString().compareTo(dates[4]) == 0){
        day5Expenses.add(expense);
      }

      else if (expense.date.toString().compareTo(dates[5]) == 0){
        day6Expenses.add(expense);
      }

      else if (expense.date.toString().compareTo(dates[6]) == 0){
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
}