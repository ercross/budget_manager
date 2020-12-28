import 'package:equatable/equatable.dart';

import '../../models/chart_data.dart';

abstract class ChartState extends Equatable {
  const ChartState();
  
  @override
  List<Object> get props => [];
}

class ChartInitial extends ChartState {
  const ChartInitial();
}

class EmptyChart extends ChartState {
  const EmptyChart();
}

class ChartDataSet extends ChartState {
  final ChartData chartData;

  const ChartDataSet(this.chartData);

  @override
  List<Object> get props => [chartData];
}

class NewCurrencySymbol extends ChartState {
  final String currencySymbol;

  const NewCurrencySymbol(this.currencySymbol);

  @override
  List<Object> get props => [currencySymbol];
}
