import 'package:equatable/equatable.dart';

import '../../models/chart_data.dart';

abstract class ChartState extends Equatable {
  const ChartState();
  
  @override
  List<Object> get props => [];
}

class ChartInitial extends ChartState {
  final ChartData initialChartData;

  const ChartInitial(this.initialChartData);

  @override
  List<Object> get props => [initialChartData];
}

// class ChartLastLoaded extends ChartState {
  
// }

class ChartDataSet extends ChartState {
  final ChartData chartData;

  const ChartDataSet(this.chartData);

  @override
  List<Object> get props => [chartData];
}
