import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

import '../screens/search_result_screen.dart';
import '../repository/db_tables.dart';
import '../models/expense.dart';
import '../repository/repository.dart';
import 'expense_card.dart';

enum SearchBy { date, amount, title }

class Search {
  Future<void> searchExpense(BuildContext ctx) async {
    Navigator.of(ctx).pop();
    switch (await showDialog<SearchBy>(
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
                    Navigator.pop(context, SearchBy.date);
                  }),
              SimpleDialogOption(
                  child: const Text("amount",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchBy.amount);
                  }),
              SimpleDialogOption(
                  child: const Text("title",
                      style:
                          const TextStyle(color: Colors.black, fontSize: 13)),
                  onPressed: () {
                    Navigator.pop(context, SearchBy.title);
                  })
            ],
          );
        })) {
      case SearchBy.date:
        DatePicker.showDatePicker(ctx,
            showTitleActions: true,
            currentTime: DateTime.now(), onConfirm: (selectedDate) async {
          if (selectedDate == null) {
            return;
          }
          final List<Expense> expenses = await Repository.repository.getAll(
              ExpenseTable.tableName,
              where: "date=?",
              whereArgs: [selectedDate.millisecondsSinceEpoch]);
          _displaySearchResult(
              ctx: ctx,
              expenses: expenses,
              pageTitle:
                  "expenses for ${DateFormat('MMM d, yyyy').format(selectedDate)}");
        });
        break;

      case SearchBy.amount:
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
                          SnackBar(
                              content: Text("$value is not a valid amount"));
                          return 0;
                        });
                        if (amount == 0) {
                          return;
                        }
                        Navigator.of(ctx).pop();
                        final List<Expense> expenses = await Repository
                            .repository
                            .getAll(ExpenseTable.tableName,
                                where: "${ExpenseTable.columnAmount}=?",
                                whereArgs: [amount]);
                        _displaySearchResult(
                            ctx: ctx,
                            expenses: expenses,
                            pageTitle: "$amount expenses");
                      },
                    ),
                  )
                ],
              );
            });
        break;
      case SearchBy.title:
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
                        final List<Expense> expenses = await Repository
                            .repository
                            .getAll(ExpenseTable.tableName,
                                where: "${ExpenseTable.columnTitle}=?",
                                whereArgs: [title]);
                        _displaySearchResult(
                            ctx: ctx,
                            expenses: expenses,
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
          _buildExpensesListView(expenses, Repository.repository.currencySymbol)
    });
  }

  Widget _buildExpensesListView(List<Expense> expenses, String currency) {
    return ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (buildContext, index) {
          return ExpenseCard(
            expense: expenses[index],
            currencySymbol: currency,
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
}
