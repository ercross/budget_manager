import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budget_manager/models/chart_data.dart';
import 'package:budget_manager/models/chart_data_date_range.dart';

import './chart_event.dart';
import './chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartInitial(ChartData(ChartDataDateRange(
    fromDate: DateTime.now().subtract( Duration(days: 6) ),
    toDate: DateTime.now()
  ))));

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {
    if (event is GetDefaultChartData) {
      final chartData = await ChartData(ChartDataDateRange()).setChartData();
      yield ChartInitial(chartData);
    }
    if (event is GetChartData) {
      final chartData = await ChartData(event.chartDataDateRange).setChartData();
      yield ChartDataSet(chartData);
    }
  }
}
