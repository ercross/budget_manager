import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/income.dart';
import '../../widgets/income_bar_chart.dart';
import '../../widgets/expense_bar_chart.dart';
import '../../models/expense.dart';
import '../../models/chart_data.dart';
import '../../models/chart_data_date_range.dart';
import '../../repository/repository.dart';
part './chart_event.dart';
part './chart_state.dart';

enum ChartName {expense, income}

class ChartBloc extends Bloc<ChartEvent, ChartState> {

  ChartBloc() : super(ChartInitial());

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {

    if (event is ChangeCurrency) {
      Repository.repository.setNewCurrency(event.currency);
      yield CurrencyChanged();
    }

    if (event is ModifyChart) {

      switch (event.chartName) {
        case ChartName.expense:
          final ChartDataDateRange dateRange = ExpenseBarChart.dateRange;
          final ChartData chartData = await ChartData(dateRange, ChartType.daily, /*expenseToDelete: event.expenseToDelete*/).generateChartData();
          yield NewChartData(ChartName.expense, chartData);
          break;

        case ChartName.income:
          final ChartDataDateRange d = IncomeBarChart.dateRange;
          final ChartData chartData = await ChartData(d, ChartType.monthly, /*incomeToDelete: event.incomeToDelete*/).generateChartData();
          yield NewChartData(ChartName.income, chartData);
          break;
      }
    }

    if (event is BuildNewChart) {
      yield NewChartData(ChartName.expense, event.chartData);
    }

    if (event is GenerateNewData) {
      final newChartData = await ChartData(event.chartDataDateRange, ChartType.daily).generateChartData();
      yield NewChartData(ChartName.expense, newChartData);
    }
  }
}
