import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/chart/chart_bloc.dart';
import '../models/chart_data_date_range.dart';
import '../models/chart_data.dart';
import '../repository/repository.dart';

///IncomeBarChart displays the statistics of incomes over the last seven month
///Option to view daily income statistics over the last seven
class IncomeBarChart extends StatefulWidget {

  final double availableSpace;
  static ChartDataDateRange dateRange;

  const IncomeBarChart(this.availableSpace);

  @override
  _IncomeBarChartState createState() => _IncomeBarChartState();
}

class _IncomeBarChartState extends State<IncomeBarChart> with WidgetsBindingObserver{

  static final DateTime todaysDate = DateTime.now();
  ChartData _chartData;
  ChartDataDateRange _dateRange = ChartDataDateRange(
        toDate: DateTime(todaysDate.year, todaysDate.month, todaysDate.day),
        fromDate: DateTime(todaysDate.year, todaysDate.month-6));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dateRange = ChartDataDateRange(
        toDate: DateTime(todaysDate.year, todaysDate.month, todaysDate.day),
        fromDate: DateTime(todaysDate.year, todaysDate.month-6));
    IncomeBarChart.dateRange = _dateRange;
    ChartData(_dateRange, ChartType.monthly).generateChartData().then((chartData) {
      setState (() => _chartData = chartData);
      BlocProvider.of<ChartBloc>(context).add(BuildNewChart(ChartName.income, chartData));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _dateRange = ChartDataDateRange(
          toDate: DateTime(DateTime.now().year, DateTime.now().month),
          fromDate: DateTime(DateTime.now().year, DateTime.now().month-6),
      );
      IncomeBarChart.dateRange = _dateRange;
      ChartData(_dateRange, ChartType.monthly).generateChartData().then((chartData) {
      setState (() {
        _chartData = chartData;
        _buildChartBody();
      });
      BlocProvider.of<ChartBloc>(context).add(BuildNewChart(ChartName.income, chartData));
    });
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        return Container(
            width: double.infinity,
            height: widget.availableSpace,
            margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 3, right: 3),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).accentColor,
              ),
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    height: widget.availableSpace * 0.1,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Last seven months incomes", textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'OleoScript',
                            color: Colors.white,
                            
                          ),
                        ))),
                Expanded(
                    child: _decideOn(state))
              ],
            ));
      },
    );
  }

  Widget _decideOn(ChartState state) {
    
    if (state is NewChartData && state.chartName == ChartName.income) {
      _dateRange = state.chartData.dateRange;
      this._chartData = state.chartData;
      return _buildChartBody();
    }

    if (state is CurrencyChanged) {
      return _buildChartBody();
    }
    if (_chartData == null) return _emptyChart;
    return _buildChartBody();
  }

  static const Widget _emptyChart = Text(
    "No income found",
    style: TextStyle(color: Colors.white, fontSize: 16),
  );

  Widget _buildTotalAmount() {
    int totalAmount = 0;
    if (_chartData != null) totalAmount = _chartData.totalAmount.toInt();
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Align(
        alignment: Alignment.center,
        child: const Text("total",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "OleoScript",
            )),
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(bottom: 45, top: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white),
            color: Colors.white,
          ),
          child: FittedBox(
              child: Text(
            '${Repository.repository.currency}$totalAmount',
            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
          )),
        ),
      )
    ]);
  }

  Widget _buildChartBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildTotalAmount()),
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
          barTouchData: _setBarTouchData(),
          titlesData: _setTitleData(),
        ),
        swapAnimationDuration: animationDuration);
  }

  BarTouchData _setBarTouchData() {
    return BarTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: BarTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipBgColor: Color.fromRGBO(171, 39, 79, 0.2),
          getTooltipItem: (BarChartGroupData group, int groupindex,
              BarChartRodData rod, int rodIndex) {
            final double totalAmount = _chartData.timeUnitTotal[group.x];
            final String date =
                DateFormat.yMMMMd('en_US').format(_chartData.dates[group.x]);

            //return 0 is either divisor or dividend is zero
            final double percentage = _chartData.percentPerTimeUnit[group.x];
            return BarTooltipItem(
                "$date \n amount spent: $totalAmount \n % of total amount: $percentage%",
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
          }),
    );
  }

  FlTitlesData _setTitleData() {
    return FlTitlesData(
        show: true,
        leftTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (_) => TextStyle(
              color: Colors.white, 
              fontFamily: "OleoScript"),
            margin: 20,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return _chartData.barTitles[0];
                case 1:
                  return _chartData.barTitles[1];
                case 2:
                  return _chartData.barTitles[2];
                case 3:
                  return _chartData.barTitles[3];
                case 4:
                  return _chartData.barTitles[4];
                case 5:
                  return _chartData.barTitles[5];
                case 6:
                  return _chartData.barTitles[6];
                default:
                  return '';
              }
            }));
  }

  BarChartGroupData _makeAbarRod(int xAxisPosition, double yAxisValue) {
    return BarChartGroupData(x: xAxisPosition, barRods: [
      BarChartRodData(
        y: yAxisValue,
        colors: [Colors.grey],
        width: 10,
        backDrawRodData: BackgroundBarChartRodData(
            colors: [Colors.white], show: true, y: 100),
      )
    ]);
  }

  List<BarChartGroupData> _makeBarGroups() {
    return [
      _makeAbarRod(0, _chartData.percentPerTimeUnit[0]),
      _makeAbarRod(1, _chartData.percentPerTimeUnit[1]),
      _makeAbarRod(2, _chartData.percentPerTimeUnit[2]),
      _makeAbarRod(3, _chartData.percentPerTimeUnit[3]),
      _makeAbarRod(4, _chartData.percentPerTimeUnit[4]),
      _makeAbarRod(5, _chartData.percentPerTimeUnit[5]),
      _makeAbarRod(6, _chartData.percentPerTimeUnit[6]),
    ];
  }
}