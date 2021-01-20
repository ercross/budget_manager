import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/report/report_cubit.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../widgets/report_card.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../models/report.dart';

class ReportTiles extends StatefulWidget {
  final double pageHeight;

  const ReportTiles(this.pageHeight);

  @override
  _ReportTilesState createState() => _ReportTilesState();
}

class _ReportTilesState extends State<ReportTiles> with WidgetsBindingObserver{
  static int daysInYear = 365;
  List<Report> dailyReports = List<Report>();
  List<Report> weeklyReports = List<Report>();
  List<Report> monthlyReports = List<Report>();
  Report lastYearReport;

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Repository.repository.fetch(ReportTable.tableName).then((maps){
      List<Report> allReports = Report.fromMaps(maps);
      setState(() {    
        allReports.forEach((report) {
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
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState (AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      if (Repository.repository.lastReportDate.isBefore(todaysDate)) _generateYesterdayReport();

      if (Repository.repository.lastReportDate.month < todaysDate.month) _generateLastMonthReport();

      if (Repository.repository.lastReportDate.add(Duration(days:6)).isAtSameMomentAs(todaysDate)) _generateLastWeekReport();

      if (Repository.repository.lastReportDate.year < todaysDate.year) _generateLastYearReport();
    }
  }

  SpendingHabit _determineSpendingHabit(double totalIncome, double totalExpense, double actualBudget) {
    if (totalExpense > totalIncome) {
      return SpendingHabit.splasher;
    }
    if (totalIncome > totalExpense && totalIncome > actualBudget) {
      return SpendingHabit.frugal;
    }
    return SpendingHabit.economic;
  }

  //TODO: use batch operation for this
  void _generateYesterdayReport() async {
    final DateTime yesterdaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days:1));
    final List<Map<String, dynamic>> expenseMaps = await Repository.repository
      .fetch(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [yesterdaysDate.millisecondsSinceEpoch]);
    final List<Map<String, dynamic>> incomeMaps = await Repository.repository
      .fetch(IncomeTable.tableName, where: "${IncomeTable.columnDate}=?", whereArgs: [yesterdaysDate.millisecondsSinceEpoch]);
    final List<Map<String, dynamic>> budgetMaps = await Repository.repository
      .fetch(BudgetTable.tableName, 
        where: "${BudgetTable.columnType}=?, ${BudgetTable.columnStartDate}=?", 
        whereArgs: [BudgetType.daily.index, yesterdaysDate.millisecondsSinceEpoch]);
    double totalExpense = 0;
    double totalIncome = 0;
    double actualBudget = 0;
    Expense.fromMaps(expenseMaps).forEach((expense) => totalExpense += expense.amount);
    Income.fromMaps(incomeMaps).forEach((income) => totalIncome += income.amount);
    Budget.fromMaps(budgetMaps).forEach((budget) => actualBudget += budget.amount);

    Report yesterdaysReport = Report(
      budget: actualBudget,
      endDate: yesterdaysDate,
      startDate: yesterdaysDate,
      expense: totalExpense,
      income: totalIncome,
      type: ReportType.daily,
      habit: _determineSpendingHabit(totalIncome, totalExpense, actualBudget)
      );

      //check that list, dailyReport, is not full
      if (dailyReports.length < daysInYear+1) {
        dailyReports.add(yesterdaysReport);
      }
      else {
        dailyReports.sort((currentReport, nextReport) {
        return currentReport.startDate.millisecondsSinceEpoch.compareTo(nextReport.startDate.millisecondsSinceEpoch);
        });
        Repository.repository.delete(tableName: ReportTable.tableName, 
          where: "${ReportTable.columnId}=?", targetValues: [dailyReports[0].id]);
        dailyReports.removeAt(0);
        if (DateTime.now().year % 4 == 0) daysInYear = 366; else daysInYear = 365;
        dailyReports.add(yesterdaysReport);
      }
      Repository.repository.insert(ReportTable.tableName, yesterdaysReport.toMap());
  }

  void _generateLastWeekReport() async {

    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime sevenDaysAgo = todaysDate.subtract(Duration(days: 6));
    const int numberOfDays = 7;
    List<DateTime> dates = List<DateTime>();
    for (int i=1; i<numberOfDays; i++) {
      dates.add(sevenDaysAgo.add(Duration(days: i)));
    }

    final List<List<Map<String, dynamic>>> expenseMapsList = await Repository.repository
      .batchFetch(ExpenseTable.tableName, "${ExpenseTable.columnDate}=?", [...dates]);
    final List<List<Map<String, dynamic>>> incomeMapsList = await Repository.repository
      .batchFetch(IncomeTable.tableName, "${IncomeTable.columnDate}=?", [...dates]);
    final List<Map<String, dynamic>> budgetMap = await Repository.repository
      .fetch(BudgetTable.tableName, where: "${BudgetTable.columnStartDate}=?", whereArgs: [sevenDaysAgo]);

    double totalExpense = 0; 
    double totalIncome = 0;
    expenseMapsList.forEach((expenseMaps) =>Expense.fromMaps(expenseMaps).forEach((expense) =>totalExpense += expense.amount));
    incomeMapsList.forEach((incomeMaps) =>Income.fromMaps(incomeMaps).forEach((income) =>totalIncome += income.amount));
    final double lastWeekBudget = Budget.fromMap(budgetMap[0]).amount;

    final Report lastWeekReport = Report(
      budget: lastWeekBudget,
      expense: totalExpense,
      income: totalIncome,
      type: ReportType.weekly,
      startDate: sevenDaysAgo,  
      endDate:todaysDate,
      habit: _determineSpendingHabit(totalIncome, totalExpense, lastWeekBudget)
     );

    //shrink list if full
    if (weeklyReports.length < 53) { //53 is used to target when the list is full, since list length is 52
        weeklyReports.add(lastWeekReport);
    }
    else {
      weeklyReports.sort((currentReport, nextReport) {
        return currentReport.startDate.millisecondsSinceEpoch.compareTo(nextReport.startDate.millisecondsSinceEpoch);
      });
      Repository.repository.delete(tableName: ReportTable.tableName, 
          where: "${ReportTable.columnId}=?", targetValues: [weeklyReports[0].id]);
      dailyReports.removeAt(0); 
      weeklyReports.add(lastWeekReport);
    }
    Repository.repository.insert(ReportTable.tableName, lastWeekReport.toMap());
  }

  void _generateLastMonthReport() async {
    final DateTime lastMonth = DateTime(DateTime.now().year, DateTime.now().month);

    final List<List<Map<String, dynamic>>> expenseMapsList = await Repository.repository
      .batchFetch(ExpenseTable.tableName, "${ExpenseTable.columnMonthAdded}=?", [lastMonth]);
    final List<List<Map<String, dynamic>>> incomeMapsList = await Repository.repository
      .batchFetch(IncomeTable.tableName, "${IncomeTable.columnMonth}=?", [lastMonth]);
    final List<Map<String, dynamic>> budgetMap = await Repository.repository
      .fetch(BudgetTable.tableName, where: "${BudgetTable.columnMonthAdded}=?, ${BudgetTable.columnType}=?", 
        whereArgs: [lastMonth, BudgetType.monthly.index]);

    double totalExpense = 0; 
    double totalIncome = 0;
    expenseMapsList.forEach((expenseMaps) =>Expense.fromMaps(expenseMaps).forEach((expense) =>totalExpense += expense.amount));
    incomeMapsList.forEach((incomeMaps) =>Income.fromMaps(incomeMaps).forEach((income) =>totalIncome += income.amount));
    final double lastMonthBudget = Budget.fromMap(budgetMap[0]).amount;

    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final Report lastMonthReport = Report(
      budget: lastMonthBudget,
      expense: totalExpense,
      income: totalIncome,
      type: ReportType.weekly,
      startDate: DateTime(todaysDate.year, todaysDate.month-1, todaysDate.day),  
      endDate:todaysDate.subtract(Duration(days:1)),
      habit: _determineSpendingHabit(totalIncome, totalExpense, lastMonthBudget)
     );
    
    //shrink list if full
    if (monthlyReports.length < 13) { //13 is used to target when the list is full, since list length is 12
        monthlyReports.add(lastMonthReport);
    }
    else {
      monthlyReports.sort((currentReport, nextReport) {
      return currentReport.startDate.millisecondsSinceEpoch.compareTo(nextReport.startDate.millisecondsSinceEpoch);
    });
    Repository.repository.delete(tableName: ReportTable.tableName, 
          where: "${ReportTable.columnId}=?", targetValues: [monthlyReports[0].id]);
    dailyReports.removeAt(0); 
    monthlyReports.add(lastMonthReport);
    }

    monthlyReports.add(lastMonthReport);
    Repository.repository.insert(ReportTable.tableName, lastMonthReport.toMap());
  }

  void _generateLastYearReport() async {
    double totalExpense = 0;
    double totalIncome = 0;

    final List<Map<String, dynamic>> budgetMap = await Repository.repository
      .fetch(BudgetTable.tableName, where: "${BudgetTable.columnYearAdded}=?, ${BudgetTable.columnType}", 
        whereArgs: [DateTime(DateTime.now().year-1).millisecondsSinceEpoch, BudgetType.yearly.index]);
    final double lastYearBudget = Budget.fromMap(budgetMap[0]).amount;
    monthlyReports.forEach((monthReport) {
      totalExpense += monthReport.expense;
      totalIncome += monthReport.income;
    });

    final DateTime todaysDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime startOfLastYear = DateTime(todaysDate.year-1, todaysDate.month, todaysDate.day);
    final DateTime endOfLastYear = DateTime(todaysDate.year-1, todaysDate.month, todaysDate.day).subtract(Duration(days:1));
    if (lastYearReport != null) {
      Repository.repository.delete(tableName: ReportTable.tableName, where: "${ReportTable.columnId}=?", targetValues: [lastYearReport.id]);
    }
    lastYearReport = Report(
      budget: lastYearBudget,
      income: totalIncome,
      expense: totalExpense,
      type: ReportType.daily,
      endDate: endOfLastYear,
      startDate: startOfLastYear,
      habit: _determineSpendingHabit(totalIncome, totalExpense, lastYearBudget)
    );
    Repository.repository.insert(ReportTable.tableName, lastYearReport.toMap());
  }

  BuildContext ctx;
  @override
  Widget build(BuildContext context) {

    ctx = context;

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state is DailyReports) {
          return Column(
            children: [
              _buildPageTitle(ReportType.daily),
              Expanded(child: _buildList(context, dailyReports))
            ],
          );
        }

        if (state is WeeklyReports) {
          return Column (
            children: [
              _buildPageTitle(ReportType.weekly),
              Expanded(child: _buildList(context, weeklyReports)),
            ],
          );
        }

        if (state is MonthlyReports) {
          return Column (
            children: [
              _buildPageTitle(ReportType.monthly),
              Expanded(child:_buildList(context, monthlyReports)),
            ],);
        }

        if (state is YearlyReports) {
          if (lastYearReport == null) {
            return Column(
            children: [
              _buildPageTitle(ReportType.yearly),
              Expanded(child: _buildList(context, null),)
            ],
          );  
          }
          return Column(
            children: [
              _buildPageTitle(ReportType.yearly),
              Expanded(child: _buildList(context, [lastYearReport]),)
            ],
          );
        }
        return Column(
            children: [
              _buildPageTitle(ReportType.daily),
              Expanded(child: _buildList(context, []),)
            ],
          );
      },
    );
  }

  Widget _buildEmptyList (BuildContext context) {
    return Center(child: Text("Report Not Ready. Please check back",style: TextStyle(
        fontSize: 20, color: Theme.of(context).accentColor.withOpacity(0.5), fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold
      )));
  }

  Widget _buildPageTitle (ReportType reportType) {
    switch (reportType) {
      case ReportType.daily:
        return _buildTitleText("Daily Reports");
        break;
      case ReportType.weekly:
        return _buildTitleText("Weekly Reports");
        break;
      case ReportType.monthly:
        return _buildTitleText("Monthly Reports");
        break;
      case ReportType.yearly:
        return _buildTitleText("Last Year Report");
        break;
      default: 
        return Text("This is an error you shouldn't see");
    }
  }

  Widget _buildTitleText (String titleText) {
    return Container(
      height: widget.pageHeight * 0.1,
      color: Theme.of(ctx).primaryColor,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      child: Center(child: Text(titleText, style: TextStyle(fontSize: 20, color:Colors.white, fontWeight: FontWeight.bold ),))
    );
  }

  Widget _buildList(BuildContext context, List<Report> reports) {
    if (reports == null || reports.isEmpty) {
      return _buildEmptyList(context);
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return ReportCard(reports[index]);
        },
      ),
    );
  }
}