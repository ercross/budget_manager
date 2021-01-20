part of './chart_bloc.dart';

abstract class ChartEvent extends Equatable {

  const ChartEvent();

  @override
  List<Object> get props => [];
}

class BuildNewChart extends ChartEvent {
  final ChartName chartName;
  final ChartData chartData;

  const BuildNewChart(this.chartName, this.chartData);

  @override
  List<Object> get props => [chartData];
}

class ModifyChart extends ChartEvent {
  final ChartName chartName;
  final Expense expense;
  final Income income;

  const ModifyChart(this.chartName, this.expense, {this.income});

  @override
  List<Object> get props => [chartName, expense, income];
}

class GenerateNewData extends ChartEvent {
  final ChartName chartName;
  final ChartDataDateRange chartDataDateRange;

  const GenerateNewData(this.chartName, this.chartDataDateRange);

  @override
  List<Object> get props => [chartDataDateRange];
}

class ChangeCurrency extends ChartEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}
