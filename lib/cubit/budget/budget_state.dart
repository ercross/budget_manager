part of 'budget_cubit.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetAdded extends BudgetState {
  final Budget budget;

  const BudgetAdded(this.budget);

  @override
  List<Object> get props => [budget];
}

class BudgetDeleted extends BudgetState {
  final int id;

  const BudgetDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class DailyBudgets extends BudgetState {}

class WeeklyBudgets extends BudgetState {}

class MonthlyBudgets extends BudgetState {}

class YearlyBudget extends BudgetState {}
