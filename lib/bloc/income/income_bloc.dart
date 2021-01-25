import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../../models/income.dart';
import '../../repository/db_tables.dart';
import '../../repository/repository.dart';

part 'income_event.dart';
part 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  IncomeBloc() : super(IncomeInitial());

  @override
  Stream<IncomeState> mapEventToState(IncomeEvent event) async* {
    if (event is ChangeCurrency) {
      yield CurrencyChanged(event.currency);
    }

    if (event is FetchIncomesFor) {
      final List<Map<String, dynamic>> maps = await Repository.repository
        .fetch(IncomeTable.tableName, where: "${IncomeTable.columnMonth}=?", whereArgs: [event.month.millisecondsSinceEpoch]);
      yield CurrentDateIncomes(Income.fromMaps(maps));
    }

    if (event is AddIncome) {
      List<Income> incomes;
      if (!event.income.date.isAtSameMomentAs(MiddleNavBarCubit.incomePageDateF)) {
         final List<Map<String, dynamic>> maps = await Repository.repository.fetch(IncomeTable.tableName, 
            where: "${IncomeTable.columnMonth}=?", whereArgs: [event.income.date.millisecondsSinceEpoch]);
         incomes = Income.fromMaps(maps);
      }
      yield NewIncomeAdded(event.income, incomes);
    }

    if (event is DeleteIncome) {
      yield RemoveIncome(event.id);
    }
  }
}
