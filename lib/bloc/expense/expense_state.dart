import 'package:equatable/equatable.dart';
 
import '../../models/expense.dart';

abstract class ExpenseState extends Equatable{

  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseStateInitial extends ExpenseState{}

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

class ENewCurrencySymbol extends ExpenseState {
  final String currencySymbol;

  const ENewCurrencySymbol(this.currencySymbol);

  @override
  List<Object> get props => [currencySymbol];
}

