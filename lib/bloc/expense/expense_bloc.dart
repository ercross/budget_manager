import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/middlenavbar_cubit/middlenavbar_cubit.dart';
import '../../models/expense.dart';
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

    if (event is ChangeCurrency) {
      yield CurrencyChanged(event.currency);
    }

    if (event is FetchExpensesFor) {
      final List<Map<String, dynamic>> maps = await Repository.repository
        .fetch(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [event.date.millisecondsSinceEpoch]);
      yield CurrentDate(Expense.fromMaps(maps));
    }

    if (event is AddExpense) {
      List<Expense> expenses; 
      if (!event.expense.date.isAtSameMomentAs(MiddleNavBarCubit.expensePageDateF)) {
        List<Map<String, dynamic>> maps = await Repository.repository.fetch(ExpenseTable.tableName, 
          where: "${ExpenseTable.columnDate}=?", whereArgs: [event.expense.date.millisecondsSinceEpoch]);
        expenses = Expense.fromMaps(maps);
      }
      yield ExpenseStateIncreased(event.expense, expenses);
    }

    if (event is DeleteExpense) {
      yield RemoveExpense(event.id);
    }
  }
}