import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/repository.dart';
import '../../repository/database_provider.dart';
import './expense_event.dart';
import './expense_state.dart';

export './expense_event.dart';
export './expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {

  final Repository repository;

  ExpenseBloc(this.repository) : super(ExpenseStateInitial());

  @override
  Stream<ExpenseState> mapEventToState (ExpenseEvent event) async*{
    if (event is FetchExpenses) {
      yield ExpenseStateFetched(event.expenses);
    }
    if (event is AddExpense) {
      repository.insert(ExpenseTable.tableName, event.expense);
      yield ExpenseStateLoaded(event.expense);
    }
    if (event is DeleteExpense) {
      repository.delete(tableName: ExpenseTable.tableName, where: "id=?", targetValues: [event.id]);
      yield ExpenseStateReduced(event.id);
    }
  }
}