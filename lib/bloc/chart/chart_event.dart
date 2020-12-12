import 'package:budget_manager/models/chart_data_date_range.dart';
import 'package:equatable/equatable.dart';

abstract class ChartEvent extends Equatable {
  const ChartEvent();

  @override
  List<Object> get props => [];
}

class GetDefaultChartData extends ChartEvent {
  final ChartDataDateRange chartDataDateRange = ChartDataDateRange();

  GetDefaultChartData();

  @override
  List<Object> get props => [chartDataDateRange];
}

class GetChartData extends ChartEvent {
  final ChartDataDateRange chartDataDateRange;

  const GetChartData(this.chartDataDateRange);

  @override
  List<Object> get props => [chartDataDateRange];
}
