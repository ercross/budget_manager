import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trackIt/models/budget.dart';
import 'package:trackIt/repository/db_tables.dart';
import 'package:trackIt/repository/repository.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit() : super(BudgetInitial());

  void add(Budget budget) {
    Repository.repository.insert(BudgetTable.tableName, budget.toMap());
    emit(BudgetAdded(budget));
  }

  void deleteBudget (int id) {
    Repository.repository.delete(tableName: BudgetTable.tableName, where: "${BudgetTable.columnId}=?", targetValues: [id]);
    emit(BudgetDeleted(id));
  }

  void getDailyBudgets() => emit(DailyBudgets());

  void getWeeklyBudgets() => emit(WeeklyBudgets());

  void getMonthlyBudgets() => emit(MonthlyBudgets());

  void getThisYearBudget() => emit(ThisYearBudget());
}
