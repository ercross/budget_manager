import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trackIt/models/budget.dart';
import 'package:trackIt/models/expense.dart';
import 'package:trackIt/models/income.dart';
import 'package:trackIt/models/report.dart';
import 'package:trackIt/models/week.dart';
import 'package:trackIt/repository/db_tables.dart';
import 'package:trackIt/repository/repository.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {

  ReportCubit() : super(ReportInitial(dailyReports));

  void getDailyReports() async {

    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
   
    //if a report was prepared today for yesterday, then yesterday's date == lastDailyReportDate
    //If today is now set to tomorrow, lastDailyReportDate will be two days before today, hence the addition of one day
    //then to prepare report for yesterday (i.e., the previous today referred to on the first line),
    //we prepare for lastReportDate.add(Duration(days: 1))
    if (Repository.repository.lastDailyReportDate.add(Duration(days: 2)).isAtSameMomentAs(todaysDate)) {
      final Report value = await _generateYesterdayReport();
      _saveYesterdayReport(value);
    }  
    emit(DailyReports(dailyReports));
  }

  void getWeeklyReports() async {
    final Week thisWeek =  Weeks(inYear: Year(DateTime.now().year)).getWeekByDate(DateTime.now());
    
    //if the lastWeeklyReportDate was two weeks ago, then prepare report for last week
    if (Repository.repository.lastWeeklyReportDate + 2 == thisWeek.number) {
      final Report value = await _generateLastWeekReport();
      _saveLastWeekReport(value);
    }
    emit(WeeklyReports(weeklyReports));
  }

  void getMonthlyReports() async {

    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final double thisMonth = double.parse("${DateTime.now().year}.${todaysDate.month}");

    //if the lastMonthlyReportDate was two months ago, then prepare report for last month
    double dateCheck = Repository.repository.lastMonthlyReportDate;
    if(dateCheck == double.parse("${DateTime.now().year-1}.12")) dateCheck = double.parse("${DateTime.now().year}.2");
    else dateCheck += 0.2;
    if ( dateCheck == thisMonth){
      final Report value = await _generateLastMonthReport();
      _saveLastMonthReport(value);
    }
    emit(MonthlyReports(monthlyReports));
  }

  void getYearlyReports() async {

    //if the lastYearlyReportDate was two years ago, then prepare report for last year
    if (Repository.repository.lastYearlyReportDate + 2 == DateTime.now().year.toDouble()) {
      await _generateLastYearReport();
    }
    emit(LastYearReport(lastYearReport));
  }

  int daysInYear = Year(DateTime.now().year).numberOfDays;

  ///dailyReports contains last 365/366 days daily reports, depending on if this year is leap year
  static List<Report> dailyReports = List<Report>();

  ///weeklyReports contains last 52/53 days daily reports, depending on the number of weeks in this year
  static List<Report> weeklyReports = List<Report>();

  ///monthlyReports contains last 12 months reports
  static List<Report> monthlyReports = List<Report>();

  static Report lastYearReport;

  //initReports fetches reports from database, initializing the class' static list fields
  //must be called at app start
  static Future initReports() async {
    final List<Map<String, dynamic>> maps = await Repository.repository.fetch(ReportTable.tableName);
    Report.fromMaps(maps).forEach((report) {
          switch (report.type) {
            case ReportType.daily:
              dailyReports.add(report);
              break;
            case ReportType.weekly:
              weeklyReports.add(report);
              break;
            case ReportType.monthly:
              monthlyReports.add(report);
              break;
            case ReportType.yearly:
              lastYearReport = report;
              break;
          }
        });
  }

  SpendingHabit _determineSpendingHabit(
      double totalIncome, double totalExpense, double actualBudget) {
    if (totalExpense > totalIncome) {
      return SpendingHabit.splasher;
    }
    if (totalIncome > totalExpense && totalIncome > actualBudget) {
      return SpendingHabit.frugal;
    }
    return SpendingHabit.economic;
  }

  Future<Report> _generateYesterdayReport() async {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime yesterdaysDate = todaysDate.subtract(Duration(days: 1));

    final List<Map<String, dynamic>> expenseMaps = await Repository.repository
        .fetch(ExpenseTable.tableName,
            where: "${ExpenseTable.columnDate}=?",
            whereArgs: [yesterdaysDate.millisecondsSinceEpoch]);

    final List<Map<String, dynamic>> incomeMaps = await Repository.repository
        .fetch(IncomeTable.tableName,
            where: "${IncomeTable.columnDate}=?",
            whereArgs: [yesterdaysDate.millisecondsSinceEpoch]);

    final List<Map<String, dynamic>> budgetMaps = await Repository.repository
        .fetch(BudgetTable.tableName,
            where: "${BudgetTable.columnDateNumber}=?",
            whereArgs: [yesterdaysDate.millisecondsSinceEpoch]);

    double totalExpense = 0;
    double totalIncome = 0;
    double actualBudget = 0;
    Expense.fromMaps(expenseMaps)
        .forEach((expense) => totalExpense += expense.amount);
    Income.fromMaps(incomeMaps)
        .forEach((income) => totalIncome += income.amount);
    Budget.fromMaps(budgetMaps)
        .forEach((budget) => actualBudget += budget.amount);

    Report yesterdaysReport = Report(
        budget: actualBudget,
        typeDate: 0.0,
        dateNumber: yesterdaysDate.millisecondsSinceEpoch,
        expense: totalExpense,
        income: totalIncome,
        type: ReportType.daily,
        habit: _determineSpendingHabit(totalIncome, totalExpense, actualBudget));

    return yesterdaysReport;
  }

  void _saveYesterdayReport(Report value) {

      //check that list, dailyReport, is not full
    if (dailyReports.length < daysInYear + 1) {
       dailyReports.add(value);
    } 
    else {
      //sort dailyReports numerically and delete the earliest
      dailyReports.sort((currentReport, nextReport) => currentReport.dateNumber.compareTo(nextReport.dateNumber));
      Repository.repository.delete( tableName: ReportTable.tableName, where: "${ReportTable.columnId}=?",
          targetValues: [dailyReports[0].id]);
      dailyReports.removeAt(0);
      dailyReports.add(value);
    }

    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime yesterdaysDate = todaysDate.subtract(Duration(days: 1));
    Repository.repository.setLastDailyReportDate(yesterdaysDate);
    Repository.repository.insert(ReportTable.tableName, value.toMap());
  }
  

  Future<Report> _generateLastMonthReport() async {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final double thisMonth = double.parse("${DateTime.now().year}.${todaysDate.month}");
    final List<DateTime> dates = List<DateTime>();
    final double lastMonth = thisMonth - 0.1;
    DateTime lastMonthStarts;
    DateTime lastMonthEnds;

    if (todaysDate.month == 1) {
      lastMonthStarts = DateTime(todaysDate.year - 1, 12, 1);
      lastMonthEnds = DateTime(todaysDate.year - 1, 12, 31);
    } else {
      lastMonthStarts = DateTime(todaysDate.year, todaysDate.month - 1, 1);
      lastMonthEnds = DateTime(todaysDate.year, todaysDate.month, 1).subtract(Duration(days: 1));
    }

    for (DateTime currentDate = lastMonthStarts; currentDate.isBefore(lastMonthEnds)
                    ; currentDate = currentDate.add(Duration(days: 1))) {
      dates.add(currentDate);
    }
    dates.add(lastMonthEnds);

    final List<List<Map<String, dynamic>>> expenseMapsList =
        await Repository.repository.batchFetch(
            ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", dates);
    final List<List<Map<String, dynamic>>> incomeMapsList =
        await Repository.repository.batchFetch(
            IncomeTable.tableName, "${IncomeTable.columnDate}=?", dates);
    final List<Map<String, dynamic>> budgetMap = await Repository.repository
        .fetch(BudgetTable.tableName,
            where: "${BudgetTable.columnTypeDate}=?", whereArgs: [lastMonth]);

    double totalExpense = 0;
    double totalIncome = 0;
    double totalBudget = 0;
    expenseMapsList.forEach((expenseMaps) => Expense.fromMaps(expenseMaps)
        .forEach((expense) => totalExpense += expense.amount));
    incomeMapsList.forEach((incomeMaps) => Income.fromMaps(incomeMaps)
        .forEach((income) => totalIncome += income.amount));
    Budget.fromMaps(budgetMap)
        .forEach((budget) => totalBudget += budget.amount);

    final Report lastMonthReport = Report(
        budget: totalBudget,
        expense: totalExpense,
        income: totalIncome,
        type: ReportType.weekly,
        typeDate: lastMonth,
        dateNumber: 0,
        habit: _determineSpendingHabit(totalIncome, totalExpense, totalBudget));

    return lastMonthReport;
  }  
    
  void _saveLastMonthReport(Report value) {
    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final double thisMonth = double.parse("${DateTime.now().year}.${todaysDate.month}");
    final double lastMonth = thisMonth - 0.1;
    //shrink list if full
    if (monthlyReports.length < 13) {
      //13 is used to target when the list is full, since list length is 12
      monthlyReports.add(value);
    } 
    else {
      monthlyReports.sort((currentReport, nextReport) => currentReport.typeDate.compareTo(nextReport.typeDate));
      Repository.repository.delete(tableName: ReportTable.tableName, where: "${ReportTable.columnId}=?",
          targetValues: [monthlyReports[0].id]);
      dailyReports.removeAt(0);
      monthlyReports.add(value);
    }

    Repository.repository.insert(ReportTable.tableName, value.toMap());
    Repository.repository.setLastMonthlyReportDate(lastMonth);
  }

  Future<Report> _generateLastWeekReport() async {
    final Week thisWeek = Weeks(inYear: Year(DateTime.now().year)).getWeekByDate(DateTime.now());
    final List<DateTime> dates = List<DateTime>();
    final Week lastWeek = Weeks(inYear: Year(DateTime.now().year)).getWeekByNumber(thisWeek.number - 1);
    
    for (DateTime currentDate = lastWeek.starts; currentDate.isBefore(lastWeek.ends); currentDate = currentDate.add(Duration(days: 1))) {
      dates.add(currentDate);
    }
    dates.add(lastWeek.ends);
    print("the dates are $dates");
    final List<List<Map<String, dynamic>>> expenseMapsList =
        await Repository.repository.batchFetch(
            ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", dates);
    final List<List<Map<String, dynamic>>> incomeMapsList =
        await Repository.repository.batchFetch(
            IncomeTable.tableName, "${IncomeTable.columnDate}=?", dates);
    final List<Map<String, dynamic>> budgetMap = await Repository.repository
        .fetch(BudgetTable.tableName,
            where: "${BudgetTable.columnDateNumber}=?",
            whereArgs: [lastWeek.number]);
    
    double totalExpense = 0;
    double totalIncome = 0;
    double totalBudget = 0;
    expenseMapsList.forEach((expenseMaps) => Expense.fromMaps(expenseMaps)
        .forEach((expense) => totalExpense += expense.amount));
    incomeMapsList.forEach((incomeMaps) => Income.fromMaps(incomeMaps)
        .forEach((income) => totalIncome += income.amount));
  
    Budget.fromMaps(budgetMap)
        .forEach((budget) => totalBudget += budget.amount);

    final Report lastWeekReport = Report(
        budget: totalBudget,
        expense: totalExpense,
        income: totalIncome,
        typeDate: double.parse(
            "${DateTime.now().year}.${DateTime.now().month}${lastWeek.number}"),
        dateNumber: lastWeek.number,
        type: ReportType.weekly,
        habit: _determineSpendingHabit(totalIncome, totalExpense, totalBudget));
    return lastWeekReport;
  }

  void _saveLastWeekReport(Report value) {
    final Week thisWeek = Weeks(inYear: Year(DateTime.now().year)).getWeekByDate(DateTime.now());
    final int lastWeek = thisWeek.number - 1;

     //shrink list if full
    if (weeklyReports.length < Weeks(inYear: Year(DateTime.now().year)).totalNumberOfWeeks + 1) {
      weeklyReports.add(value);
    } 
    else {
      weeklyReports.sort((currentReport, nextReport) => currentReport.dateNumber.compareTo(nextReport.dateNumber));
      Repository.repository.delete( tableName: ReportTable.tableName, where: "${ReportTable.columnId}=?",
          targetValues: [weeklyReports[0].id]);
      dailyReports.removeAt(0);
      weeklyReports.add(value);
    }
    Repository.repository.setLastWeeklyReportDate(lastWeek);
    Repository.repository.insert(ReportTable.tableName, value.toMap());
  }

  Future<Report> _generateLastYearReport() async {
    double totalExpense = 0;
    double totalIncome = 0;
    double totalBudget = 0;
    final int lastYear = (DateTime.now().year - 1);

    //I could have just fetched totalExpenses and totalIncome from reports of the last 12 months
    //But to avoid possible occurence of error through monthlyReports.length, this case is preferred
    final List<Map<String, dynamic>> budgetMap = await Repository.repository
        .fetch(BudgetTable.tableName,
            where: "${BudgetTable.columnTypeDate}=?", whereArgs: [lastYear]);
    final List<Map<String, dynamic>> expenseMaps = await Repository.repository
        .fetch(ExpenseTable.tableName,
            where: "${ExpenseTable.columnYearAdded}=?",
            whereArgs: [lastYear]);
    final List<Map<String, dynamic>> incomeMaps = await Repository.repository
        .fetch(IncomeTable.tableName,
            where: "${IncomeTable.columnYear}=?",
            whereArgs: [lastYear]);

    Expense.fromMaps(expenseMaps)
        .forEach((expense) => totalExpense += expense.amount);
    Income.fromMaps(incomeMaps)
        .forEach((income) => totalIncome += income.amount);
    Budget.fromMaps(budgetMap)
        .forEach((budget) => totalBudget += budget.amount);

    if (lastYearReport != null) {
      Repository.repository.delete(
          tableName: ReportTable.tableName,
          where: "${ReportTable.columnId}=?",
          targetValues: [lastYearReport.id]);
    }
   lastYearReport = Report(
        budget: totalBudget,
        income: totalIncome,
        expense: totalExpense,
        type: ReportType.daily,
        typeDate: lastYear.toDouble(),
        dateNumber: 0,
        habit: _determineSpendingHabit(totalIncome, totalExpense, totalBudget));

    Repository.repository.setLastYearlyReportDate(lastYear.toDouble());
    Repository.repository.insert(ReportTable.tableName, lastYearReport.toMap());
    return lastYearReport;
  }
}
