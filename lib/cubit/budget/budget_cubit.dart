import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/budget.dart';
import '../../repository/db_tables.dart';
import '../../repository/repository.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit() : super(BudgetInitial());

  void add(Budget budget) {
    Repository.repository.insert(BudgetTable.tableName, budget.toMap());
    emit(BudgetAdded(budget));
  }

  void getDailyBudgets() => emit(DailyBudgets());

  void getWeeklyBudgets() => emit(WeeklyBudgets());

  void getMonthlyBudgets() => emit(MonthlyBudgets());

  void getThisYearBudget() => emit(YearlyBudget());
}
