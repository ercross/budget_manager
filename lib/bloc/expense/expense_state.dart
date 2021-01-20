import 'package:equatable/equatable.dart';
 
import '../../models/expense.dart';

abstract class ExpenseState extends Equatable{

  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseStateInitial extends ExpenseState{}

///ExpenseStateIncreased is yielded when a new expense is added to trackIt
///if expense.date.isAtTheSameMomentAs(MiddleNavBarCubit.expensePageDate), then expenses is null
///otherwise, expenses contains expenses entered for expense.date is generated
class ExpenseStateIncreased extends ExpenseState {
  final Expense expense;
  final List<Expense> expenses;

  const ExpenseStateIncreased(this.expense, this.expenses);

  @override
  List<Object> get props => [expense, expenses];
}

class RemoveExpense extends ExpenseState {
  final int id;

  const RemoveExpense(this.id);

  @override
  List<Object> get props => [id];
}

class CurrentDate extends ExpenseState {
  final List<Expense> expenses;

  const CurrentDate(this.expenses);

  @override
  List<Object> get props => [expenses];
}

class CurrencyChanged extends ExpenseState {
  final String currency;

  const CurrencyChanged(this.currency);

  @override
  List<Object> get props => [currency];
}

