import 'package:equatable/equatable.dart';
 
import '../../models/expense.dart';

abstract class ExpenseState extends Equatable{

  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseStateInitial extends ExpenseState{
  
  const ExpenseStateInitial();
}

class ExpenseStateLoaded extends ExpenseState {
  final Expense expense;

  const ExpenseStateLoaded(this.expense);

  @override
  List<Object> get props => [expense];
}

class ExpenseStateReduced extends ExpenseState {
  final int id;

  const ExpenseStateReduced(this.id);

  @override
  List<Object> get props => [id];
}

class ExpenseStateFetched extends ExpenseState {
  final List<Expense> expenses;

  const ExpenseStateFetched(this.expenses);

  @override
  List<Object> get props => [expenses];
}