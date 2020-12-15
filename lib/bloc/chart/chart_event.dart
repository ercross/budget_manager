import 'package:equatable/equatable.dart';

import '../../models/chart_data.dart';
import '../../models/chart_data_date_range.dart';

abstract class ChartEvent extends Equatable {
  const ChartEvent();

  @override
  List<Object> get props => [];
}

class BuildEmptyChart extends ChartEvent {
}

class BuildNewChart extends ChartEvent {
  final ChartData chartData;

  const BuildNewChart(this.chartData);

  @override
  List<Object> get props => [chartData];
}

class GetNewChartData extends ChartEvent {
  final ChartDataDateRange chartDataDateRange;

  const GetNewChartData(this.chartDataDateRange);

  @override
  List<Object> get props => [chartDataDateRange];
}
