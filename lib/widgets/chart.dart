import 'package:budget_manager/models/chart_data_date_range.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/chart_data.dart';
import '../repository/repository.dart';
import '../bloc/chart/chart_bloc.dart';
import '../bloc/chart/chart_state.dart';
import '../bloc/chart/chart_event.dart';

class ExpenseManagerBarChart extends StatefulWidget {
  final double availableSpace;
  final Repository repository;

  ExpenseManagerBarChart(this.availableSpace, this.repository);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<ExpenseManagerBarChart> with WidgetsBindingObserver {
  
  ChartData _chartData;
  String _currencySymbol;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final ChartDataDateRange dateRange = widget.repository.chartDataDateRange;
    ChartData(dateRange).setChartData().then((chartData) {
      _chartData = chartData;
      BlocProvider.of<ChartBloc>(context).add(BuildNewChart(chartData));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        (Repository.repository.dateRangeAutoGen == null
            ? true
            : Repository.repository.dateRangeAutoGen)) {
      final DateTime today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final ChartDataDateRange newDateRange = ChartDataDateRange(
        toDate: today,
        fromDate: today.subtract(Duration(days: 6)),
      );
      Repository.repository.setChartDataDateRange(newDateRange);
    }
  }

  final DateFormat d = DateFormat('EEE MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    String chartTitle;

    if (_chartData?.chartDataDateRange == null ||
        _chartData.chartDataDateRange.toDate.isAtSameMomentAs(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      chartTitle = "Last seven days stastistics";
    } else {
      chartTitle =
          "${_chartData.chartDataDateRange.fromDate} to ${_chartData.chartDataDateRange.toDate}";
    }

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
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          chartTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))),
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
    if (_currencySymbol == null) {
      _currencySymbol = Repository.repository.currencySymbol;
    }

    if (state is ChartDataSet) {
      if (state.chartData == null) {
        return _emptyChartWidget;
      }
      this._chartData = state.chartData;
      return _buildChartBody();
    }

    if (state is NewCurrencySymbol) {
      _currencySymbol = state.currencySymbol;
      return _buildChartBody();
    }

    return _emptyChartWidget;
  }

  static const Widget _emptyChartWidget = Text(
    "No data loaded into chart",
    style: TextStyle(color: Colors.white, fontSize: 16),
  );

  Widget _buildTotalAmountWidget() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Align(
        alignment: Alignment.center,
        child: const Text("total",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
            '$_currencySymbol${_chartData.totalAmount.toInt()}',
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
        Expanded(child: _buildTotalAmountWidget()),
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
            final double totalAmount = _chartData.dailyExpensesTotal[group.x];
            final String date =
                DateFormat.yMMMMd('en_US').format(_chartData.dates[group.x]);

            //return 0 is either divisor or dividend is zero
            final double percentage = _chartData.percentageSpentPerDay[group.x];
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
            margin: 20,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  return _chartData.weekdaysNames[0];
                case 1:
                  return _chartData.weekdaysNames[1];
                case 2:
                  return _chartData.weekdaysNames[2];
                case 3:
                  return _chartData.weekdaysNames[3];
                case 4:
                  return _chartData.weekdaysNames[4];
                case 5:
                  return _chartData.weekdaysNames[5];
                case 6:
                  return _chartData.weekdaysNames[6];
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
        width: 13,
        backDrawRodData: BackgroundBarChartRodData(
            colors: [Colors.white70], show: true, y: 100),
      )
    ]);
  }

  List<BarChartGroupData> _makeBarGroups() {
    return [
      _makeAbarRod(0, _chartData.percentageSpentPerDay[0]),
      _makeAbarRod(1, _chartData.percentageSpentPerDay[1]),
      _makeAbarRod(2, _chartData.percentageSpentPerDay[2]),
      _makeAbarRod(3, _chartData.percentageSpentPerDay[3]),
      _makeAbarRod(4, _chartData.percentageSpentPerDay[4]),
      _makeAbarRod(5, _chartData.percentageSpentPerDay[5]),
      _makeAbarRod(6, _chartData.percentageSpentPerDay[6]),
    ];
  }
}
