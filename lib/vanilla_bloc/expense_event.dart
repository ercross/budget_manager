import '../expense.dart';

abstract class ExpenseEvent {
  final Expense expense;

  const ExpenseEvent(this.expense);
}

class AddExpense extends ExpenseEvent{
  final Expense expense;

  const AddExpense(this.expense): super(expense);

  void addExpense (List<Expense> expenses) {
    expenses.add(this.expense);
  }
}

class DeleteExpense extends ExpenseEvent{
  final Expense expense;

  const DeleteExpense(this.expense): super (expense);

  void deleteExpense (List<Expense> expenses) {
    expenses.remove(this.expense);
  }
}