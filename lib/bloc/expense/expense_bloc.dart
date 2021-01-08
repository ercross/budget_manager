import 'package:flutter_bloc/flutter_bloc.dart';

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

    if (event is ChangeCurrencySymbol) {
      yield ENewCurrencySymbol(event.currencySymbol);
    }

    if (event is FetchExpensesFor) {
      final DateTime currentDate = DateTime(event.date.year, event.date.month, event.date.day);
      final List<Expense> expenses = await Repository.repository
        .getAll(ExpenseTable.tableName, where: "${ExpenseTable.columnDate}=?", whereArgs: [currentDate.millisecondsSinceEpoch]);
      yield CurrentDate(expenses);
    }

    if (event is AddExpense) {
      final expenseDate = DateTime(event.expense.date.year, event.expense.date.month, event.expense.date.day);
      repository.insert(ExpenseTable.tableName, event.expense);
      final expenses = await Repository.repository.getAll(ExpenseTable.tableName, 
          where: "${ExpenseTable.columnDate}=?", whereArgs: [expenseDate.millisecondsSinceEpoch]);
      yield ExpenseStateIncreased(event.expense, expenses);
    }

    if (event is DeleteExpense) {
      repository.delete(tableName: ExpenseTable.tableName, where: "id=?", targetValues: [event.id]);
      yield RemoveExpense(event.id);
    }
  }
}