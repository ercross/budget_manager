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
  final DateTime month;

  const FetchIncomesFor(this.month);

  @override
  List<Object> get props => [month];
}

class ChangeCurrency extends IncomeEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}
