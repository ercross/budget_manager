import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class ExpenseManagerBarChart extends StatefulWidget {
  final double availableSpace;

  ExpenseManagerBarChart(this.availableSpace);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<ExpenseManagerBarChart> {

  ///made static const and class variable for performance gain
  ///as static const properties always return the same instance
  static const Text chartTitle = const Text(
    'Expense Manager Chart',
    style: TextStyle(
      fontSize: 20,
      fontFamily: 'OpenSans',
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final BarChart expenseBarChart = makeExpenseBarChart();
    final String totalExpenses = calculateTotalExpenses().toString();
    
    final Column totalAmountWidget =
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
          margin: EdgeInsets.fromLTRB(0, 8, widget.availableSpace * 0.035, widget.availableSpace * 0.1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white),
            color: Colors.white,
          ),
          child: FittedBox(
            child: Text('\$$totalExpenses', style: TextStyle(fontWeight: FontWeight.bold),)),
        ),
      )
    ]);

    final Row chartInfo = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: totalAmountWidget),
        expenseBarChart,
      ],
    );

    //build method return widget
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
                child: Align(alignment: Alignment.center, child: chartTitle)),
            Expanded(
                child: Align(alignment: Alignment.center, child: chartInfo)),
          ],
        ));
  }

  BarChart makeExpenseBarChart() {
    final Duration animationDuration = const Duration(milliseconds: 250);
    return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 30,
          minY: 0,
          borderData: FlBorderData(show: false),
          maxY: 100,
          barGroups: barGroups,
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
                  return 'Mn';
                case 1:
                  return 'Te';
                case 2:
                  return 'Wd';
                case 3:
                  return 'Tu';
                case 4:
                  return 'Fr';
                case 5:
                  return 'St';
                case 6:
                  return 'Sn';
                default:
                  return '';
              }
            }));
  }

  static BarChartGroupData makeBarRodData(int xAxisValue, double yAxisValue) {
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

  List<BarChartGroupData> barGroups = [
    makeBarRodData(0, 5),
    makeBarRodData(1, 16),
    makeBarRodData(2, 18),
    makeBarRodData(3, 20),
    makeBarRodData(4, 17),
    makeBarRodData(5, 19),
    makeBarRodData(6, 10),
  ];

  static double calculateTotalExpenses () {
    double totalExpenses = 0;
    //ExpenseBloc().expenses.forEach((expense) {totalExpenses += expense.amount;});
    return totalExpenses;
  }
}
