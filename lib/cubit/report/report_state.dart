part of 'report_cubit.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class DailyReports extends ReportState {}

class WeeklyReports extends ReportState {}

class MonthlyReports extends ReportState {}

class YearlyReports extends ReportState {}
