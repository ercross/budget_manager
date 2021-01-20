part of 'income_bloc.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();
  
  @override
  List<Object> get props => [];
}

class IncomeInitial extends IncomeState {}

class NewIncomeAdded extends IncomeState {
  final Income addedIncome;

  ///incomeList is the list generated if addedIncome.date.isNotAtTheSameMomentAs.IncomePageNavBarDate
  ///This enables navBar date changed to addedIncome.date
  final List<Income> incomeList; 

  const NewIncomeAdded(this.addedIncome, this.incomeList);

  @override
  List<Object> get props => [addedIncome, incomeList];
}

class RemoveIncome extends IncomeState {
  final int id;

  const RemoveIncome(this.id);

  @override
  List<Object> get props => [id];
}

class CurrentDateIncomes extends IncomeState {
  final List<Income> incomes;

  const CurrentDateIncomes(this.incomes);

  @override
  List<Object> get props => [incomes];
}

class CurrencyChanged extends IncomeState {
  final String currency;

  const CurrencyChanged(this.currency);

  @override
  List<Object> get props => [currency];
}

