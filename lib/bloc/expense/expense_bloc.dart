import 'package:budget_manager/bloc/chart/chart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/repository.dart';
import '../../repository/db_tables.dart';
import './expense_event.dart';
import './expense_state.dart';

export './expense_event.dart';
export './expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {

  final Repository repository;

  ExpenseBloc(this.repository) : super(ExpenseStateInitial());

  @override
  Stream<ExpenseState> mapEventToState (ExpenseEvent event) async*{
    if (event is ChangeCurrencySymbol) {
      yield ENewCurrencySymbol(event.currencySymbol);
    }

    if (event is FetchExpenses) {
      yield ExpenseStateFetched(event.expenses);
    }

    if (event is AddExpense) {
      repository.insert(ExpenseTable.tableName, event.expense);
      yield ExpenseStateIncreased(event.expense);
    }

    if (event is DeleteExpense) {
      repository.delete(tableName: ExpenseTable.tableName, where: "id=?", targetValues: [event.id]);
      yield ExpenseStateReduced(event.id);
    }
  }
}