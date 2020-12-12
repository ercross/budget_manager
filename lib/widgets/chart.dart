import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../bloc/chart/chart_bloc.dart';
import '../bloc/chart/chart_event.dart';
import '../bloc/chart/chart_state.dart';
import '../models/chart_data.dart';
import '../models/chart_data_date_range.dart';


class ExpenseManagerBarChart extends StatefulWidget {
  final double availableSpace;
  final ChartDataDateRange chartDataDateRange;

  ExpenseManagerBarChart(this.availableSpace, this.chartDataDateRange);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<ExpenseManagerBarChart> {
  ChartData chartData;

  @override
  void initState() {
    super.initState();
    chartData = ChartData(widget.chartDataDateRange);
    ChartData(widget.chartDataDateRange).setChartData().then((value) {
      chartData = value;
      BlocProvider.of<ChartBloc>(context)
          .add(GetChartData(widget.chartDataDateRange));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        return Container(
            width: double.infinity,
            height: widget.availableSpace,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.only(top: 5, bottom: 0, left: 10, right: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    height: widget.availableSpace * 0.1,
                    child:
                        Align(alignment: Alignment.center, child: _chartTitle)),
                Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: _makeStateDecision(state)))
              ],
            ));
      },
    );
  }

  Widget _makeStateDecision(ChartState state) {
    if (state is ChartInitial) {
      return _buildChartBody(state.initialChartData);
    }
    if (state is ChartDataSet) {
      return _buildChartBody(state.chartData);
    }
    return Container();
  }

  ///made static const and class variable for performance gain
  ///as static const properties always return the same instance
  static const Text _chartTitle = const Text(
    'expenses chart',
    style: TextStyle(
      fontSize: 20,
      fontFamily: 'OpenSans',
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildTotalAmountWidget(double totalAmount) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Align(
        alignment: Alignment.centerLeft,
        child: const Text("Total:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(5),
          width: widget.availableSpace * 0.1,
          margin: EdgeInsets.fromLTRB(
              0, 8, widget.availableSpace * 0.035, widget.availableSpace * 0.1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white),
            color: Colors.white,
          ),
          child: FittedBox(
              child: Text(
            '\$$totalAmount',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
      )
    ]);
  }

  Widget _buildChartBody(ChartData chartData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildTotalAmountWidget(chartData.totalAmount)),
        _buildExpenseBars(),
      ],
    );
  }

  BarChart _buildExpenseBars() {
    final Duration animationDuration = const Duration(milliseconds: 250);
    return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 30,
          minY: 0,
          borderData: FlBorderData(show: false),
          maxY: 100,
          barGroups: _makeBarGroups(),
          //  barTouchData: setBarTouchData(),
          titlesData: setTitleData(),
        ),
        swapAnimationDuration: animationDuration);
  }

  /*BarTouchData setBarTouchData () {

  } */

  FlTitlesData setTitleData() {
    return FlTitlesData(
        show: true,
        leftTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
            showTitles: true,
            margin: 20,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return chartData.weekdaysNames[0];
                case 1:
                  return chartData.weekdaysNames[1];
                case 2:
                  return chartData.weekdaysNames[2];
                case 3:
                  return chartData.weekdaysNames[3];
                case 4:
                  return chartData.weekdaysNames[4];
                case 5:
                  return chartData.weekdaysNames[5];
                case 6:
                  return chartData.weekdaysNames[6];
                default:
                  return '';
              }
            }));
  }

  BarChartGroupData _makeAbarRod (int xAxisValue, double yAxisValue) {
    return BarChartGroupData(x: xAxisValue, barRods: [
      BarChartRodData(
        y: yAxisValue,
        colors: [Colors.grey],
        width: 13,
        backDrawRodData: BackgroundBarChartRodData(
            colors: [Colors.white70], show: true, y: 100),
      )
    ]);
  }

  List<BarChartGroupData> _makeBarGroups() {
    return [
      _makeAbarRod(0, chartData.dailyExpensesTotal[0] ?? 0),
      _makeAbarRod(1, chartData.dailyExpensesTotal[1] ?? 0),
      _makeAbarRod(2, chartData.dailyExpensesTotal[2] ?? 0),
      _makeAbarRod(3, chartData.dailyExpensesTotal[3] ?? 0),
      _makeAbarRod(4, chartData.dailyExpensesTotal[4] ?? 0),
      _makeAbarRod(5, chartData.dailyExpensesTotal[5] ?? 0),
      _makeAbarRod(6, chartData.dailyExpensesTotal[6] ?? 0),
    ];
  }
}
