part of './chart_bloc.dart';

abstract class ChartState extends Equatable {
  const ChartState();
  
  @override
  List<Object> get props => [];
}

class ChartInitial extends ChartState {
  const ChartInitial();
}

class NewChartData extends ChartState {
  final ChartName chartName;
  final ChartData chartData;

  const NewChartData(this.chartName, this.chartData);

  @override
  List<Object> get props => [chartData, chartName];
}

class CurrencyChanged extends ChartState {
  const CurrencyChanged();
}
