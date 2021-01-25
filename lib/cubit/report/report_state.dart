part of 'report_cubit.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {
  final List<Report> dailyReports;

  const ReportInitial(this.dailyReports);
  
  @override
  List<Object> get props => [dailyReports];
}

class DailyReports extends ReportState {
  final List<Report> dailyReports;

  const DailyReports(this.dailyReports);
  
  @override
  List<Object> get props => [dailyReports];
}

class WeeklyReports extends ReportState {
  final List<Report> weeklyReports;

  const WeeklyReports(this.weeklyReports);
  
  @override
  List<Object> get props => [weeklyReports];
}

class MonthlyReports extends ReportState {
  final List<Report> monthlyReports;

  const MonthlyReports(this.monthlyReports);
  
  @override
  List<Object> get props => [monthlyReports];
}

class LastYearReport extends ReportState {
  final Report lastYearReport;

  const LastYearReport(this.lastYearReport);
  
  @override
  List<Object> get props => [lastYearReport];
}
