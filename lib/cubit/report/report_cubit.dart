import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(ReportInitial());

  void getDailyReports() async {
    emit(DailyReports());
  }

  void getWeeklyReports() async {
    emit(WeeklyReports());
  }

  void getMonthlyReports() async {
    emit(MonthlyReports());
  }

  void getYearlyReports() async {
    emit(YearlyReports());
  }
}
