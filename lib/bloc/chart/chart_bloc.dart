import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../models/chart_data.dart';
import './chart_event.dart';
import './chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {

  ChartBloc() : super(ChartInitial());

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {
    
    if( event is BuildEmptyChart) {
      yield EmptyChart();
    }

    if (event is BuildNewChart) {
      yield ChartDataSet(event.chartData);
    }

    if (event is GetNewChartData) {
      final newChartData = await ChartData(event.chartDataDateRange).setChartData();
      yield ChartDataSet(newChartData);
    }
  }
}
