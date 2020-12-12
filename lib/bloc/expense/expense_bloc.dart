import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/database_provider.dart';
import './expense_event.dart';
import './expense_state.dart';

export './expense_event.dart';
export './expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {

  final DatabaseProvider databaseProvider;

  ExpenseBloc(this.databaseProvider) : super(ExpenseStateInitial());

  @override
  Stream<ExpenseState> mapEventToState (ExpenseEvent event) async*{
    if (event is FetchExpenses) {
      yield ExpenseStateFetched(event.expenses);
    }
    if (event is AddExpense) {
      databaseProvider.insert(ExpenseTable.tableName, event.expense);
      yield ExpenseStateLoaded(event.expense);
    }
    if (event is DeleteExpense) {
      databaseProvider.delete(tableName: ExpenseTable.tableName, where: "id=?", targetValues: [event.id]);
      yield ExpenseStateReduced(event.id);
    }
  }
}