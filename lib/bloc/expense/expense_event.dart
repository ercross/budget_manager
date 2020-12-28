import 'package:equatable/equatable.dart';

import '../../models/expense.dart';

abstract class ExpenseEvent extends Equatable {

  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent{
 final int id;

 const DeleteExpense(this.id);

 @override
  List<Object> get props => [id];
}

class FetchExpenses extends ExpenseEvent {
  final List<Expense> expenses;

  const FetchExpenses(this.expenses);

  @override
  List<Object> get props => [expenses];
}

class ChangeCurrencySymbol extends ExpenseEvent {
  final String currencySymbol;

  const ChangeCurrencySymbol(this.currencySymbol);

  @override
  List<Object> get props => [currencySymbol];
}