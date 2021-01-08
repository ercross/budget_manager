import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../models/chart_data_date_range.dart';

import '../../repository/repository.dart';
import '../../models/chart_data.dart';
import './chart_event.dart';
import './chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {

  ChartBloc() : super(ChartInitial());

  @override
  Stream<ChartState> mapEventToState(ChartEvent event) async* {

    if (event is ChangeChartCurrencySymbol) {
      yield NewCurrencySymbol(event.currencySymbol);
    }
    
    if( event is BuildEmptyChart) {
      yield EmptyChart();
    }

    if (event is AddOrRemoveExpenseFromChart) {
      final DateTime date = DateTime(event.expense.date.year, event.expense.date.month, event.expense.date.day);
      final ChartDataDateRange dateRange = Repository.repository.chartDataDateRange;
      if (_dateIsContainedInRange(dateRange, date)) {
        final ChartData chartData = await ChartData(dateRange).setChartData();
        yield ChartDataSet(chartData);
      }
    }

    if (event is BuildNewChart) {
      yield ChartDataSet(event.chartData);
    }

    if (event is GetNewChartData) {
      final newChartData = await ChartData(event.chartDataDateRange).setChartData();
      yield ChartDataSet(newChartData);
    }
  }

  bool _dateIsContainedInRange(ChartDataDateRange range, DateTime date) {
    DateTime currentDate = range.fromDate;
    while (!currentDate.isAfter(range.toDate)) {
      if (date.isAtSameMomentAs(currentDate)) {
        return true;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
    return false;
  }
}
