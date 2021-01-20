part of 'income_bloc.dart';

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object> get props => [];
}

class AddIncome extends IncomeEvent {
  final Income income;

  const AddIncome(this.income);

  @override
  List<Object> get props => [income];
}

class DeleteIncome extends IncomeEvent{
 final int id;

 const DeleteIncome(this.id);

 @override
  List<Object> get props => [id];
}

class FetchIncomesFor extends IncomeEvent {
  final DateTime date;

  const FetchIncomesFor(this.date);

  @override
  List<Object> get props => [date];
}

class ChangeCurrency extends IncomeEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}
