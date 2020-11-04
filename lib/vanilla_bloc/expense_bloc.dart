import 'dart:async';
import './expense_event.dart';
import '../models/expense.dart';

class ExpenseBloc {

  List<Expense> _expenses = [
      new Expense(id: 1, amount: 20, date: DateTime.now(), title: "trip to Lagos"),
      new Expense(id: 2, amount: 30, date: DateTime.now(), title: "Feeding today")
      ];

  List<Expense> get expenses => _expenses;

  final StreamController<List<Expense>> _stateStreamController = new StreamController<List<Expense>>();

  StreamSink<List<Expense>> get _stateStreamInput => _stateStreamController.sink;
  Stream<List<Expense>> get stateStreamOutput => _stateStreamController.stream;

  final StreamController<ExpenseEvent> _eventStreamController = new StreamController<ExpenseEvent>();

  Sink<ExpenseEvent> get eventInput  => _eventStreamController.sink;
  
  ExpenseBloc () {
    _eventStreamController.stream.listen(_mapEventToState);
  }

  void _mapEventToState (ExpenseEvent expenseEvent) {
    if (expenseEvent is AddExpense) {
      AddExpense(expenseEvent.expense).addExpense(_expenses);
    }
    if (expenseEvent is DeleteExpense) {
      DeleteExpense(expenseEvent.expense).deleteExpense(_expenses);
    }
    _stateStreamInput.add(_expenses);
  }

  void dispose() {
    _stateStreamController.close();
    _eventStreamController.close();
  }
}