import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:trackIt/screens/income_screen.dart';

import '../models/income.dart';
import '../screens/expenses_screen.dart';
import '../screens/search_result_screen.dart';
import '../repository/db_tables.dart';
import '../models/expense.dart';
import '../repository/repository.dart';
import '../widgets/expense_card.dart';
import '../widgets/income_card.dart';

enum Search {expense, income, budget, report} ///order must align with pageview ordering
enum SearchExpenseBy { date, amount, title }
enum SearchIncomeBy {date, amount, source}

//todo refactor: remove WET code
class Searcher {

  Future<void> search (Search what, BuildContext ctx) {
    switch(what) {
      case Search.expense:
        return searchExpense(ctx);
        break;
      case Search.income:
        return searchIncome (ctx);
        break;
      case Search.budget:
        return Future<void>((){});
        break;
      case Search.report:
        return Future<void>((){});
        break;
      default:
        return Future<void>((){});
    }
  }

  Future<void> searchIncome(BuildContext ctx) async {
    if (Navigator.of(ctx).canPop())
      Navigator.of(ctx).pop();
    switch (await showDialog<SearchIncomeBy>(
        context: ctx,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("search income by"),
            contentPadding: EdgeInsets.all(10),
            children: [
              SimpleDialogOption(
                  child: const Text("date",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchIncomeBy.date);
                  }),
              SimpleDialogOption(
                  child: const Text("amount",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchIncomeBy.amount);
                  }),
              SimpleDialogOption(
                  child: const Text("source",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchIncomeBy.source);
                  })
            ],
          );
        })) {
      case SearchIncomeBy.date:
        DatePicker.showDatePicker(ctx,
            showTitleActions: true,
            currentTime: DateTime.now(),
            maxTime: DateTime.now(),
            onConfirm: (selectedDateF) async {
          if (selectedDateF == null) {
            return;
          }
          selectedDateF = DateTime(selectedDateF.year, selectedDateF.month, selectedDateF.day);
          final List<Map<String, dynamic>> maps = await Repository.repository.fetch(
              IncomeTable.tableName,
              where: "${IncomeTable.columnDate}=?",
              whereArgs: [selectedDateF.millisecondsSinceEpoch]);
          _displayIncomesSearchResult(
              ctx: ctx,
              incomes: Income.fromMaps(maps),
              pageTitle:
                  "incomes for ${DateFormat('MMM d, yyyy').format(selectedDateF)}");
        });
        break;

      case SearchIncomeBy.amount:
        showDialog(
            context: ctx,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: [
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        enabled: true,
                        labelText: "enter amount",
                      ),
                      enabled: true,
                      keyboardType: TextInputType.number,
                      onSubmitted: (amountAsString) async {
                        final double amount =
                            double.parse(amountAsString, (value) {
                              Navigator.of(context).pop();
                          Scaffold.of(IncomePage.ctx).showSnackBar(SnackBar(
                              content: Text("$value is not a valid amount"),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),));
                              
                          return 0;
                        });
                        if (amount == 0) {
                          return;
                        }
                        Navigator.of(ctx).pop();
                        final List<Map<String, dynamic>> maps = await Repository
                            .repository
                            .fetch(IncomeTable.tableName,
                                where: "${IncomeTable.columnAmount}=?",
                                whereArgs: [amount]);
                        _displaySearchResult( //todo 3
                            ctx: ctx,
                            expenses: Expense.fromMaps(maps),
                            pageTitle: "$amount incomes");
                      },
                    ),
                  )
                ],
              );
            });
        break;
      case SearchIncomeBy.source:
        showDialog(
            context: ctx,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: [
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        enabled: true,
                        labelText: "enter source",
                      ),
                      enabled: true,
                      keyboardType: TextInputType.text,
                      onSubmitted: (source) async {
                        Navigator.of(ctx).pop();
                        final List<Map<String, dynamic>> maps = await Repository
                            .repository
                            .fetch(IncomeTable.tableName,
                                where: "${IncomeTable.columnSource}=?",
                                whereArgs: [source]);
                        _displaySearchResult(
                            ctx: ctx,
                            expenses: Expense.fromMaps(maps),
                            pageTitle: "incomes from source: $source");
                      },
                    ),
                  )
                ],
              );
            });
        break;
    }
  }

  void _displayIncomesSearchResult(
      {BuildContext ctx, List<Income> incomes, String pageTitle}) {
    Navigator.of(ctx).pushNamed(SearchResultPage.routeName, arguments: {
      SearchResultPage.pageTitleKey: pageTitle,
      SearchResultPage.listViewKey:
          _buildIncomeListView(incomes)
    });
  }

  Widget _buildIncomeListView(List<Income> incomes) =>
      (incomes == null || incomes.isEmpty)
          ? Center(
              child: Text(
                "No Incomes Found",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple.withOpacity(0.5),
                    fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: incomes.length,
              itemBuilder: (buildContext, index) {
                return IncomeCard(
                  income: incomes[index],
                  delete: (income) {
                    incomes.remove(incomes[index]);
                    Repository.repository.delete(
                        tableName: IncomeTable.tableName, 
                        where: "${IncomeTable.columnId}=?",
                        targetValues: [incomes[index].id]);
                  },
                );
              });

  //**************************************SearchExpense functionality************************************
  Future<void> searchExpense(BuildContext ctx) async {
    if (Navigator.of(ctx).canPop())
      Navigator.of(ctx).pop();
    switch (await showDialog<SearchExpenseBy>(
        context: ctx,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text("Search expense by"),
            contentPadding: EdgeInsets.all(10),
            children: [
              SimpleDialogOption(
                  child: const Text("date",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchExpenseBy.date);
                  }),
              SimpleDialogOption(
                  child: const Text("amount",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchExpenseBy.amount);
                  }),
              SimpleDialogOption(
                  child: const Text("title",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchExpenseBy.title);
                  })
            ],
          );
        })) {
      case SearchExpenseBy.date:
        DatePicker.showDatePicker(ctx,
            showTitleActions: true,
            currentTime: DateTime.now(),
            maxTime: DateTime.now(), 
            onConfirm: (selectedDateF) async {
          if (selectedDateF == null) {
            return;
          }
          selectedDateF = DateTime(selectedDateF.year, selectedDateF.month, selectedDateF.day);
          final List<Map<String, dynamic>> maps = await Repository.repository.fetch(
              ExpenseTable.tableName,
              where: "${ExpenseTable.columnDate}=?",
              whereArgs: [selectedDateF.millisecondsSinceEpoch]);
          _displaySearchResult(
              ctx: ctx,
              expenses: Expense.fromMaps(maps),
              pageTitle:
                  "expenses for ${DateFormat('MMM d, yyyy').format(selectedDateF)}");
        });
        break;

      case SearchExpenseBy.amount:
        showDialog(
            context: ctx,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: [
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        enabled: true,
                        labelText: "enter amount",
                      ),
                      enabled: true,
                      keyboardType: TextInputType.number,
                      onSubmitted: (amountAsString) async {
                        final double amount =
                            double.parse(amountAsString, (value) {
                              Navigator.of(context).pop();
                          Scaffold.of(ExpensesPageBody.ctx).showSnackBar(SnackBar(
                              content: Text("$value is not a valid amount"),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),));
                          return 0;
                        });
                        if (amount == 0) {
                          return;
                        }
                        Navigator.of(ctx).pop();
                        final List<Map<String, dynamic>> maps = await Repository
                            .repository
                            .fetch(ExpenseTable.tableName,
                                where: "${ExpenseTable.columnAmount}=?",
                                whereArgs: [amount]);
                        _displaySearchResult(
                            ctx: ctx,
                            expenses: Expense.fromMaps(maps),
                            pageTitle: "$amount expenses");
                      },
                    ),
                  )
                ],
              );
            });
        break;
      case SearchExpenseBy.title:
        showDialog(
            context: ctx,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: [
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        enabled: true,
                        labelText: "enter title",
                      ),
                      enabled: true,
                      keyboardType: TextInputType.text,
                      onSubmitted: (title) async {
                        Navigator.of(ctx).pop();
                        final List<Map<String, dynamic>> maps = await Repository
                            .repository
                            .fetch(ExpenseTable.tableName,
                                where: "${ExpenseTable.columnTitle}=?",
                                whereArgs: [title]);
                        _displaySearchResult(
                            ctx: ctx,
                            expenses: Expense.fromMaps(maps),
                            pageTitle: "expenses with title: $title");
                      },
                    ),
                  )
                ],
              );
            });
        break;
    }
  }

  void _displaySearchResult(
      {BuildContext ctx, List<Expense> expenses, String pageTitle}) {
    Navigator.of(ctx).pushNamed(SearchResultPage.routeName, arguments: {
      SearchResultPage.pageTitleKey: pageTitle,
      SearchResultPage.listViewKey:
          _buildExpensesListView(expenses)
    });
  }

  Widget _buildExpensesListView(List<Expense> expenses) =>
      (expenses == null || expenses.isEmpty)
          ? Center(
              child: Text(
                "No Expenses Found",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple.withOpacity(0.5),
                    fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (buildContext, index) {
                return ExpenseCard(
                  expense: expenses[index],
                  deleteExpense: (expense) {
                    expenses.remove(expenses[index]);
                    Repository.repository.delete(
                        tableName: ExpenseTable.tableName,
                        where: "${ExpenseTable.columnId}=?",
                        targetValues: [expenses[index].id]);
                  },
                );
              });

}
