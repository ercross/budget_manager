import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../bloc/income/income_bloc.dart';
import '../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../widgets/income_card.dart';
import '../models/income.dart';
import '../repository/db_tables.dart';
import '../repository/repository.dart';
import '../bloc/chart/chart_bloc.dart' as chart;
import 'middle_nav_bar.dart';

class IncomeTiles extends StatefulWidget {
  const IncomeTiles();

  @override
  _IncomeTiles createState() => _IncomeTiles();
}

class _IncomeTiles extends State<IncomeTiles> with WidgetsBindingObserver{

  List<Income> incomes = List<Income>();

  @override
  void initState() { 
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final DateTime thisMonth = DateTime(DateTime.now().year, DateTime.now().month);
    Repository.repository.fetch(IncomeTable.tableName, 
      where: "${IncomeTable.columnMonth}=?", whereArgs: [thisMonth.millisecondsSinceEpoch]).then((maps){
        setState(() {
          incomes = Income.fromMaps(maps);
        });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState (AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final DateTime thisMonthsDate = DateTime(DateTime.now().year, DateTime.now().month);
      Repository.repository.fetch(IncomeTable.tableName, where: "${IncomeTable.columnDate}=?", whereArgs: [thisMonthsDate.millisecondsSinceEpoch]).then((maps){
        setState(() {
          incomes = Income.fromMaps(maps);
          BlocProvider.of<MiddleNavBarCubit>(context).emitInitial(MiddleNavBarOn.incomePage);
        });
      });
    }
  }

  final Widget _emptyListView = Center(
    child: Text(
      "No income added yet",
      style: TextStyle(
          fontSize: 20,
          color: Colors.green.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic),
    ),
  );

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<IncomeBloc, IncomeState>(
          builder: (context, state) {
            if (state is CurrentDateIncomes) {
              incomes = state.incomes;
              return _buildListView(incomes);
            }

            if (state is CurrencyChanged) {
              return _buildListView(incomes);
            }
            
            if (state is NewIncomeAdded) {
              final DateTime addedIncomeDate = DateTime(state.addedIncome.date.year, state.addedIncome.date.month);
              if (MiddleNavBarCubit.incomePageDateF.isAtSameMomentAs(addedIncomeDate)) {

                //TODO: This is a fix for a bug encountered that causes income added to be readded again 
                //once a swipe is made off the page and back to the page. Find the problem, rather than this hack
                // if (incomes.isNotEmpty) incomes.removeWhere((income) { return
                //   income.amount == state.addedIncome.amount
                //   && income.date == state.addedIncome.date
                //   && income.source == state.addedIncome.source;} );
                if(!incomes.contains(state.addedIncome)) incomes.add(state.addedIncome);
                return _buildListView(incomes); 
              }
              else {
                incomes = state.incomeList;
                final DateTime thisMonth = DateTime(DateTime.now().year, DateTime.now().month);
                BlocProvider.of<MiddleNavBarCubit>(context).emitNew(
                  MiddleNavBar(
                    currentDate: state.addedIncome.date,
                    enableOldestDateButton: Repository.repository.oldestIncomeDate.isBefore(addedIncomeDate),
                    enablePreviousDayButton: addedIncomeDate.subtract(Duration(days: 1)).isAfter(Repository.repository.oldestIncomeDate),
                    enableNextDayButton: addedIncomeDate.add(Duration(days: 1)).isBefore(thisMonth),
                    enableTodayButton: addedIncomeDate.isBefore(thisMonth),),
                  MiddleNavBarOn.incomePage);  
                  return _buildListView(incomes);
              }
            }

            if (state is RemoveIncome) {
              incomes.removeWhere((income) => income.id == state.id);
              return _buildListView(incomes);
            }

            return _buildListView(incomes);
          },
        );
  }

  Widget _buildListView(List<Income> incomes) {
    if (incomes == null || incomes.isEmpty) {
      return _emptyListView;
    }
    
    return ListView.builder(
        itemCount: incomes.length,
        itemBuilder: (buildContext, index) {
          return IncomeCard(
            income: incomes[index],
            delete: _delete,
          );
        });
  }

  void _delete(Income income) {
    if(!income.date.isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) return;
    else {
      Repository.repository.delete(tableName: IncomeTable.tableName, where: "${IncomeTable.columnId}=?", targetValues: [income.id]);
      BlocProvider.of<chart.ChartBloc>(context)
        .add(chart.ModifyChart(chart.ChartName.income, null, income: income));
      BlocProvider.of<IncomeBloc>(context).add(DeleteIncome(income.id));
    }
  }
}